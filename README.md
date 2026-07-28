# Digitale Edition der Korrespondenz Leopold I

* data is fetched from <https://github.com/loepold-briefe/leopold-briefe-data>
* build with [DSE-Static-Cookiecutter](https://github.com/acdh-oeaw/dse-static-cookiecutter)

## development

You need JAVA, ANT and Python (via [uv](https://docs.astral.sh/uv/))

```bash
git clone https://github.com/leopold-briefe/leopold-briefe-static.git
cd leopold-briefe-static
./shellscripts/fetch_data.sh
./shellscripts/process_data.sh
ant
```

But to be on the save side, always have a look at [.github/workflows/build.yml](.github/workflows/build.yml)

## start dev server

* `cd html/`
* `uv run -m http.server`
* go to [http://0.0.0.0:8000/](http://0.0.0.0:8000/)

## publish as GitHub Page

* go to <https://https://github.com/loepold-briefe/leopold-briefe-static/actions/workflows/build.yml>
* click the `Run workflow` button

## Python scripting

The project uses [uv](https://docs.astral.sh/uv/), as Python package and project manager.

## Licenses

This project is released under the [MIT License](LICENSE)

### third-party JavaScript libraries

The code for all third-party JavaScript libraries used is included in the `html/vendor` folder, their respective licenses can be found either in a `LICENSE.txt` file or directly in the header of the `.js` file

### SAXON-HE

The projects also includes Saxon-HE, which is licensed separately under the Mozilla Public License, Version 2.0 (MPL 2.0). See the dedicated [LICENSE.txt](saxon/notices/LICENSE.txt)
