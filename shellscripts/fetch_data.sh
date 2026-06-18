#!/bin/bash
rm -rf data

echo "fetching transkriptions from leopold-briefe-data"
curl -LO https://github.com/loepold-briefe/leopold-briefe-data/archive/refs/heads/main.zip
unzip main
mv ./leopold-briefe-data-main/data/ ./data/
rm -rf ./leopold-briefe-data-main
rm main.zip


echo "fetching entity data from leopold-entities"
curl -LO https://github.com/loepold-briefe/leopold-entities/archive/refs/heads/main.zip
unzip main
mv ./leopold-entities-main/data/indices ./data/
rm main.zip
rm -rf ./leopold-entities-main

echo "fetch imprint"
./shellscripts/dl_imprint.sh
