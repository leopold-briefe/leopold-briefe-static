import glob
import os
from collections import defaultdict

import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import any_xpath

listevent_xml = os.path.join("data", "indices", "listevent.xml")
files = glob.glob(f"{os.path.join('data', 'editions')}/*.xml")

print(f"adds 'referenced_letters' to {listevent_xml}")


lookup_dict = defaultdict(list)
for x in files:
    f_name = os.path.split(x)[-1]
    doc = TeiReader(x)
    title = doc.any_xpath(".//tei:title[@type='main']")[0].text
    letter_type = doc.any_xpath(".//tei:origin/tei:term")[0].text
    date = doc.any_xpath(".//tei:origDate/@when-iso")[0]
    lookup_dict[date].append(f"{title} ({letter_type})#{f_name}")

lookup_dict = dict(lookup_dict)

doc = TeiReader(listevent_xml)
for x in doc.any_xpath(".//tei:listEvent[@xml:id='letters']/tei:event"):
    date = any_xpath(x, "./tei:label")[0].text
    try:
        items = lookup_dict[date]
        for bad in any_xpath(
            x, "./tei:listBibl[@key='referenced_letters' or @n='referenced_letters']"
        ):
            bad.getparent().remove(bad)
        listbibl = ET.Element(
            "{http://www.tei-c.org/ns/1.0}listBibl", {"n": "referenced_letters"}
        )
        listplace = any_xpath(x, "./tei:listPlace")
        if listplace:
            x.insert(x.index(listplace[0]), listbibl)
        else:
            x.append(listbibl)
        for item in items:
            title, f_name = item.split("#")
            ET.SubElement(
                listbibl, "{http://www.tei-c.org/ns/1.0}bibl", {"key": f_name}
            ).text = title
    except KeyError:
        pass
    ET.indent(doc.any_xpath(".")[0], space="   ")
    doc.tree_to_file(listevent_xml)
