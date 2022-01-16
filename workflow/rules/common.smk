from snakemake.utils import validate
from pathlib import Path
import pandas as pd

##### load config and sample sheets #####

configfile: "config/config.yaml"
#validate(config, schema="../schemas/config.schema.yaml")

run_name = config["run"]["name"]

samples = (
    pd.read_csv(config["run"]["samples"], sep="\t", dtype={"ID": str})
    .set_index("ID", drop=False)
    .sort_index()
)

validate(samples, schema="../schemas/samples.schema.yaml")

units = (
    pd.read_csv(config["run"]["units"], sep="\t", dtype={"ID": str, "unit_name": str})
    .set_index(["ID"], drop=False)
    .sort_index()
)

validate(units, schema="../schemas/units.schema.yaml")

## HELPER
SAMPLES = samples.ID.to_list()
UNITS = units.unit_name.to_list()
CONDITIONS = samples.Condition.to_list()
PE = ["fq1", "fq2"]

def get_pe_raw(sample):
    x = units.loc[sample, ["fq1", "fq2"]].dropna()
    return x.values

wildcard_constraints:
    sample="|".join(SAMPLES),
    unit="|".join(UNITS),