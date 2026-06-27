uv run add-attributes -g "data/meta/*.xml" -b "https://leopold-briefe.acdh.oeaw.ac.at"
uv run add-attributes -g "data/editions/*.xml" -b "https://leopold-briefe.acdh.oeaw.ac.at"
uv run add-attributes -g "data/indices/*.xml" -b "https://leopold-briefe.acdh.oeaw.ac.at"


uv run denormalize-indices -f "./data/editions/*.xml" -i "./data/indices/*.xml"  -m ".//*[@ref]/@ref" -x ".//tei:title[@type='main']/text()"