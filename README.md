[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
![dbt version](https://img.shields.io/badge/dbt-1.10.5%20to%202.x-FF694B?logo=dbt)

# CMS Chronic Conditions

The CMS Chronic Conditions package identifies chronic conditions in Tuva's
standardized healthcare data. It applies the published CMS condition hierarchy
to diagnoses, procedures, and selected pharmacy evidence, then exposes both
event-level evidence and patient-level indicator columns. Results retain
`data_source`, so identical patient or encounter identifiers from different
source systems remain separate.

Use this package to create chronic-condition cohorts, summarize prevalence,
add patient-level condition features to analytics, or inspect the encounters
and pharmacy claims that produced each classification.

## Outputs

By default, public models are built in the `chronic_conditions` schema.

| Relation | Grain and purpose |
| --- | --- |
| `cms_chronic_conditions_long` | One row per qualifying person, evidence event, condition, and data source. Medication-derived opioid use disorder evidence can have a null encounter identifier. |
| `cms_chronic_conditions_wide` | One row per person and data source with an integer indicator column for each condition in the hierarchy. |

The staging relations are package implementation details and should not be
used as stable downstream interfaces.

## Prerequisites and dependency ownership

Use this package in a dbt project that already installs a compatible version
of Tuva Core and supplies Tuva's standardized healthcare models. In a normal
Tuva deployment, the connector is the root dbt project and owns the Tuva Core
dependency. This package therefore does not install or pin Tuva Core itself;
it expects `core__patient`, `core__encounter`, `core__condition`,
`core__procedure`, and `core__pharmacy_claim` in the shared dbt graph.

The package requires dbt `>=1.10.5,<3.0.0`. Its only declared package
dependency is `dbt-labs/dbt_utils`, used to construct the wide output.

## Installation

Add the package to the root project's `packages.yml`:

```yaml
packages:
  - package: tuva-health/cms_chronic_conditions
    version: 0.2.0
```

Before a release is available from the dbt Package Hub, install that release
directly from GitHub:

```yaml
packages:
  - git: "https://github.com/tuva-health/cms_chronic_conditions.git"
    revision: v0.2.0
```

Then resolve dependencies and build the package from the root project:

```shell
dbt deps
dbt build --select package:cms_chronic_conditions
```

Keep the package seed in the first build so its released condition hierarchy
is loaded before the models run.

## Configuration

The defaults read Tuva Core directly. The database, schema, and each input can
be overridden in the root project's `dbt_project.yml`:

```yaml
vars:
  cms_chronic_conditions_database: analytics
  cms_chronic_conditions_schema: chronic_conditions

  # Optional relation overrides. Values must render as valid dbt relations.
  cms_chronic_conditions_patient_override: "{{ ref('my_patient') }}"
  cms_chronic_conditions_encounter_override: "{{ ref('my_encounter') }}"
  cms_chronic_conditions_condition_override: "{{ ref('my_condition') }}"
  cms_chronic_conditions_procedure_override: "{{ ref('my_procedure') }}"
  cms_chronic_conditions_pharmacy_claim_override: "{{ ref('my_pharmacy_claim') }}"
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `cms_chronic_conditions_database` | `tuva_database`, then the target database | Places package models in a selected database. |
| `cms_chronic_conditions_schema` | `<tuva_schema_prefix>_chronic_conditions`, then `chronic_conditions` | Places package models in a selected schema. |
| `cms_chronic_conditions_<input>_override` | matching Core relation | Overrides one of the five inputs listed above. |
| `core_<input>_override` | unset | Uses a connector-wide Core override when no package-specific override is supplied. |
| `cms_chronic_conditions_data_asset_version` | `1.0.0` | Selects the independently versioned public hierarchy snapshot. |

Package-specific input overrides take precedence over connector-wide Core
overrides, which take precedence over the default Core relations.

## Data assets

The checked-in hierarchy CSV is a header-only dbt loader contract. At build
time, Tuva Core's shared seed loader retrieves the released contents from:

```text
s3://tuva-public-resources/data-marts/cms-chronic-conditions/1.0.0/
```

The same snapshot is mirrored to GCS and Azure. Package code and data assets
have independent version numbers; the `0.2.0` package release intentionally
uses the `1.0.0` data-asset snapshot. Change the asset-version variable only
when testing another published, compatible snapshot.

## Supported platforms

The current end-to-end Tuva 1.0 support matrix is Snowflake, BigQuery,
Databricks, Microsoft Fabric, Redshift, and DuckDB. The package SQL also has
portability handling for SQL Server and has received package-level Athena
review, but those adapters are outside the current end-to-end Tuva Core
support matrix. Use a dbt adapter and Tuva connector version supported by your
root project; end-to-end support depends on that complete stack, not this
package alone.

## Documentation and support

- Read the [Tuva CMS Chronic Conditions
  documentation](https://thetuvaproject.com/data-marts/chronic-conditions).
- Review column-level contracts in [`models/_models.yml`](models/_models.yml).
- Report bugs or request enhancements in [GitHub
  Issues](https://github.com/tuva-health/cms_chronic_conditions/issues).
- Join the [Tuva community on
  Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-4663yf7du-MUIbAJPxHD65byDtAHwSyg).

Contributions are welcome through pull requests. Please describe the behavior
being changed and include the narrowest dbt unit or data test that demonstrates
it. Validate changes from the integration project or another consuming root
project that installs Tuva Core.

This project is licensed under the [Apache License 2.0](LICENSE).
