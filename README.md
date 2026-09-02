[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![dbt logo and version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=1.10.5%20to%202.x&color=orange)

# CMS Chronic Conditions

## 🔗  Quick Links
- [Docs](https://thetuvaproject.com/data-marts/chronic-conditions): Learn about the Tuva Project data model
- [Knowledge Base](https://thetuvaproject.com/docs/intro): Learn about claims data fundamentals and how to do claims data analytics
<br/><br/>

## 🧰 What does this project do?

The Tuva Project's CMS Chronic Conditions package creates chronic condition flags on your patient population for 75 different chronic conditions. 

## 🔌 What databases are supported?

This package has been tested on **Snowflake**, **Redshift** and **BigQuery**.

## 📚 What versions of dbt are supported?

This package requires dbt versions `>=1.10.5,<3.0.0` and a functional dbt project.

## ✅ How do I use this dbt package?

To run this package, please refer to the instructions in the Tuva Project [README](https://github.com/tuva-health/tuva-core#readme).

## Data assets

Seed contents are stored under
`s3://tuva-public-resources/data-marts/cms-chronic-conditions/<asset-version>/`
and mirrored to GCS and Azure. The checked-in CSV file contains only the
header required by dbt.

`cms_chronic_conditions_data_asset_version` selects the folder and defaults to
`1.0.0`. Package code and data assets are versioned independently and are
coordinated manually. Cloud manifests record the asset inventory, provenance,
and release status; dbt loads the configured path without reading them.

## 🙋🏻‍♀️ ****How is this package maintained and how do I contribute?****

The Tuva Project team maintaining this package **only** maintains the latest version of the package. We highly recommend you stay consistent with the latest version.

Have an opinion on the mappings? Notice any bugs when installing and running the package? If so, we highly encourage and welcome feedback! While we work on a formal process in Github, we can be easily reached in our Slack community.

## 🤝 Join our community!

Join our growing community of healthcare data practitioners in [Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-16iz61187-G522Mc2WGA2mHF57e0il0Q)!
