import json
import os

from acdh_cidoc_pyutils import extract_begin_end
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import any_xpath, get_xmlid

print("Collection data for calendar")

files = ["listletter.xml", "mentioned-letters.xml"]

files = [os.path.join("data", "indices", x) for x in files]

json_data_dir = os.path.join("html", "js-data")
os.makedirs(json_data_dir, exist_ok=True)


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
        item["label"] = y.attrib["n"]
        item["kind"] = kind
        date_node = any_xpath(y, ".//tei:date")[0]
        item["not_before"], item["not_after"] = extract_begin_end(date_node)
        item["date"] = item["not_before"]
        items.append(item)

save_path = os.path.join(json_data_dir, "calendarData.json")
with open(save_path, "w", encoding="utf-8") as fp:
    json.dump(items, fp, ensure_ascii=False)

print(f"saving {len(items)} event data points to {save_path}")
