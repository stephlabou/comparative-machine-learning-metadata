This repository includes data and code for Labou et al. 2024. [full citation and link TBD]

## Directory Overview


```bash
├───Analysis
│   ├───Figures
│   │   ├───Figure1
│   │   │   └───repository_dates
│   │   └───Figure2
│   │       └───file_ext_data
│   ├───Repository_calculations
│   │   ├───Dataverse
│   │   ├───Dryad
│   │   ├───Figshare
│   │   ├───Kaggle
│   │   ├───OpenML
│   │   ├───UCI
│   │   ├───UCSD
│   │   └───Zenodo
│   └───utils
└───Extract
    ├───data
    ├───docs
    ├───images
    ├───notebooks
    ├───scrapers
    │   ├───term_scrapers
    │   ├───term_type_scrapers
    │   ├───type_scrapers
    │   └───web_scrapers
    ├───tests
    └───utils
```

### `Extract\` folder

The `Extract\` folder contains scripts used to query the APIs for and/or web scrape the following repositories:

**ML-focused repositories**

* [Kaggle](https://www.kaggle.com/)
  * Kaggle is a popular ML data and model hub, frequently used by students and others learning ML. Documentation can be variable, but components are intended to be reused.
  
* [OpenML](https://www.openml.org/)
  * Classifies ML components experiments into 5 semi-hierarchical categories, each with specific documentation fields: datasets, tasks, flows, runs, and studies.
  
* [UC Irvine Machine Learning Repository](https://archive.ics.uci.edu/)
  * Hosts training and test datasets, with broad variability in documentation. At time of project, no public API; metadata extracted by web scraping. Note that at the time of this project, this site was in beta phase, with content transitioning from the prior site to this new site. _Be aware that  code may no longer work with finalized site_. 

**Generalist repositories**

* [Figshare](https://figshare.com/)
  * A non-curated generalist repository, with a soft limit of 20 GB. Offers several Creative Commons and open source licenses.
  
* [Zenodo](https://zenodo.org/)
  * A non-curated generalist repository, free of charge up to 50 GB per dataset. Integration with GitHub allows users to publish their GitHub repositories easily. Offers hundreds of open licenses.
  
* [Dryad](https://datadryad.org/stash)
  * A lightly curated generalist repository for datasets, with a soft limit of 300 GB/dataset. Assigns the CC0 public domain dedication to all submissions.
  
* [Harvard Dataverse](https://dataverse.harvard.edu/)
  * Offers tiered curation with deposits and a limit of 1 TB. In addition to serving as a repository for research data, depositors can submit their data and code as a container “dataverse” with all necessary data and metadata. CC0 is highly encouraged, and applied by default.
  
Note: UC San Diego Library metadata from Labou et al. 2024 was extracted manually - see paper for full details.

`Extracts\notebooks\` contains repository-specific code (Python in Jupyter Notebook) and instructions to query and extract metadata for all objects matching specified search terms. See Labou et al. 2024 for full details and methodology. 

### `Analysis\` folder

#### Summary statistics and tables
The `Repository_calculations` folder contains a subfolder for each repository that contains Jupyter notebook used in analysis. Note that actual metadata extracts are too large for GitHub and are instead available in the [associated collection in the UC San Diego Library Research Data Digital Collections](https://doi.org/10.6075/J0JS9QMH). To run the notebooks, download the associated metadata extract (JSON format except for UC San Diego Library metadata) and save it in the same repository folder.

For example, current GitHub directory structure for sample repositories is:

```bash
├───Analysis
│   ├───Repository_calculations
│   │   │
│   │   ├───UCI
│   │   │       UCI.ipynb
│   │   │
│   │   ├───UCSD
│   │   │       UCSD.ipynb
```
```bash
and the expected structure of notebooks to run as intended is:
  ├───Analysis
    │   ├───Repository_calculations
    │   │   ├───UCI
    │   │   │       UCI.ipynb
    │   │   │       uci_datasets.json
    │   │   │
    │   │   ├───UCSD
    │   │   │       UCSD.ipynb
    │   │   │       UCSD_2020-02-24.xlsx
```

The file `Analysis\utils\crosswalk.py` reflects the contents of Table B in Labou et al. 2024 and is used to subset data extracts for each repository based on metadata field name.

##### Figures
Aggregated data and code for creating figures can be found in `Analysis\Figures`. 

The `Figure1` folder contains a .csv file for each repository with object-level publication year as extracted in each repository analysis notebook. The R file `Figure1.R` contains code to recreate Figure 1 from Labou et al. 2024.

The `Figure2` folder contains a .csv file for each repository with raw file extensions as extracted in item 19 in each repository analysis notebook. The R file `Figure2.R` contains code to clean and standardize file extensions, crosswalk extensions to format category, and create Figure 2 and Table C from Labou et al. 2024.

### Funding & acknowledgements
This project was funded in part by a research grant from the Librarians Association of the University of California (LAUC). Michael Baluja wrote the code for items in `Extracts\`; Michael Baluja and Stephanie Labou collaborated on the code for items in `Analysis\`. 

### Contact
For questions or comments, please email [Stephanie Labou](mailto:slabou@ucsd.edu) or open an issue in this repository.


