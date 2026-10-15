import json
import os
import requests
from lxml import etree
from acdh_cidoc_pyutils import extract_begin_end
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import any_xpath, extract_fulltext_with_spacing, get_xmlid

print("Collection data for calendar")


list_event_xml = os.path.join("data", "indices", "listevent.xml")
doc = TeiReader(list_event_xml)


calendar_entriesJSON = requests.get("https://raw.githubusercontent.com/leopold-briefe/leopold-entities/refs/heads/main/json_dumps/calendar_entries.json").json()
events = {}
for x in doc.any_xpath(".//tei:event[@xml:id]"):
    event_id = get_xmlid(x)
    date = any_xpath(x, "./tei:label")[0].text
    # desc = extract_fulltext_with_spacing(any_xpath(x, "./tei:desc")[0])
    # Note: get the desc directly from the JSON dump
    entry_number = event_id.rsplit("-", 1)[-1]
    desc = calendar_entriesJSON.get(entry_number, {}).get("text")
    if desc is not None:
        events[date] = desc

files = ["listletter.xml", "mentioned-letters.xml"]

files = [os.path.join("data", "indices", x) for x in files]

json_data_dir = os.path.join("html", "js-data")
os.makedirs(json_data_dir, exist_ok=True)


items = []
for x in files:
    doc = TeiReader(x)
    if "mentioned" in x:
        kind = "verzeichnet/erwähnt"
    else:
        kind = "erfasst"
    for y in doc.any_xpath(".//tei:correspDesc"):
        kind_notes = any_xpath(y, ".//tei:note[@type='kind']")
        if kind_notes and kind_notes[0].text != "Original":
            continue
        
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
        try:
            date_node = any_xpath(y, ".//tei:date")[0]
        except IndexError:
            continue
        item["not_before"], item["not_after"] = extract_begin_end(date_node)
        item["date"] = item["not_before"]
        try:
            item["description"] = events[item["date"]]
        except KeyError:
            item["description"] = False
        items.append(item)


save_path = os.path.join(json_data_dir, "calendarData.json")
with open(save_path, "w", encoding="utf-8") as fp:
    json.dump(items, fp, ensure_ascii=False)

print(f"saving {len(items)} event data points to {save_path}")
