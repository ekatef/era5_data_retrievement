# ERA5 data retrievement

Un apdated workflow for data extraction using the official Copernicus API with examples of data loading scripts. The original instruction is available via https://cds.climate.copernicus.eu/api-how-to. Here we discuss implementation of these instructions and give some examples.

## Preparation

First of all, you will need to register in the Copernicus Climate Data Store (CDS). Then you may load data in the most straightforward way via the CDS graphic user interface. The interface is really beautiful. The CDS API is needed only to automate the data requests. That makes sence, for example, when loading a big data archive in smaller chunks.

API utilization is very simple, the only obstacle is connected with some preliminary adjuctments. Namely, you have to install the Python package and provide your operation system with your CDS authentification data.

You can find these authentificaiton detais via your CDS account. Click on your username in the righ upper corner after  login to Copernicus and scroll until the "API key" section. Both key values should be placed in the `.cdsapirc` file. Technical details about file location under different operaiton systems are described in the Copernicus Knowledge Base at https://confluence.ecmwf.int/display/CKB/Climate+Data+Store+%28CDS%29+infrastructure+and+API Then the Python package `cdsapi` is needed. As usuall, it's better to install it under the Python virtual environment.

The installation workflow step-by-step looks as follows:

1. Ensure that Python3 and pip package manager are installed. 

2. Install the venv package

3. Create the [virtual environment](https://docs.python.org/3/library/venv.html#venv-def) with the command

`python3 -m venv /path/to/new/virtual/environment`

## Workflow

After the initial procedures are competed, the data load workflow looks very straightforward:

1) load your virtual environment:

```bash
source path-to-you-virtual-environment/my_venv/bin/activate
```

2) check and/or modify your loading script;

3) run the script:

```python
python3 era5_wind_by_years.py
```

By default the loaded file is placed to the directory the script is working from. This location may be modified by providing the desired path as a part of the last argment in the `c.retrieve()` function.
