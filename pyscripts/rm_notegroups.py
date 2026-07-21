import glob

import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader

files = glob.glob("./data/editions/*.xml")

print(f"going to remove noteGrps from back elements in {len(files)} documents")

for x in files:
    doc = TeiReader(x)
    for bad in doc.any_xpath(".//tei:back//tei:noteGrp"):
        bad.getparent().remove(bad)
    ET.indent(doc.any_xpath(".")[0], space="   ")
    doc.tree_to_file(x)
