import os

from acdh_cidoc_pyutils import extract_begin_end
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import any_xpath, get_xmlid

files = ["listletter.xml", "mentioned-letters.xml"]

files = [os.path.join("data", "indices", x) for x in files]


items = []
for x in files:
    doc = TeiReader(x)
    if "mentioned" in x:
        kind = "verzeichent/erwähnt"
    else:
        kind = "erfasst"
    for y in doc.any_xpath(".//tei:correspDesc"):
        item = {}
        item["id"] = get_xmlid(y)
        link_to_letter = False
        try:
            if any_xpath(y, ".//tei:note[@type='file_exists']")[0].text == "1":
                link_to_letter = True
        except IndexError:
            pass
        item["link"] = link_to_letter
        item["kind"] = kind
        date_node = any_xpath(y, ".//tei:date")[0]
        item["not_before"], item["not_after"] = extract_begin_end(date_node)
        item["date"] = item["not_before"]
        items.append(item)

print(items)
