import glob
import os

import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import any_xpath, get_xmlid

print("check if transkription exists and or facs exist and deletes the file if not")

cmif_file = "./data/indices/listletter.xml"

doc = TeiReader(cmif_file)

keep_files = []

for x in doc.any_xpath(".//tei:correspDesc[@xml:id]"):
    xml_id = get_xmlid(x)
    note_grp_node = any_xpath(x, "./tei:noteGrp[@type='metadata']")[0]
    status_node = ET.SubElement(note_grp_node, "{http://www.tei-c.org/ns/1.0}note")
    status_node.attrib["type"] = "file_exists"
    status_node.text = "0"
    status_transkription = any_xpath(x, ".//tei:note[@type='status_transkription']")[
        0
    ].text
    if status_transkription == "nicht vorhanden":
        status_transkription = False

    images_on_share = any_xpath(x, ".//tei:note[@type='images_on_share']")[0]
    if images_on_share.text == "False":
        images_on_share.text = "0"
        images_on_share = False
    else:
        images_on_share.text = "1"
    if status_transkription or images_on_share:
        keep_files.append(f"{xml_id}.xml")
        status_node.text = "1"
ET.indent(doc.any_xpath(".")[0], space="   ")
doc.tree_to_file(cmif_file)


files = glob.glob("./data/editions/*.xml")

for x in files:
    try:
        TeiReader(x)
    except Exception as e:
        print(f"failed to parse {x} due to {e}")
        os.remove(x)
    filename = os.path.split(x)[-1]
    if filename in keep_files:
        pass
    else:
        os.remove(x)
