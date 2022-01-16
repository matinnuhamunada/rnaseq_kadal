import pandas as pd
from pathlib import Path
import sys

def get_trinity_samples(run_name, condition, outfile, samples_path="config/samples.tsv", units_path="config/units.tsv"):
    """
    """
    samples = (
        pd.read_csv(samples_path, sep="\t", dtype={"ID": str})
        .set_index("ID", drop=False)
        .sort_index()
        )
    
    units = (
        pd.read_csv(units_path, sep="\t", dtype={"ID": str})
        .set_index("ID", drop=False)
        .sort_index()
        )
    
    trinity = []
    
    subset = samples[samples.loc[:, "Condition"] == condition]
    for s in subset.index:
        s_dict = {}
        s_dict["Condition"] = samples.loc[s, "Condition"]
        s_dict["Replicate"] = units.loc[s, "unit_name"]
        s_dict["F"] = units.loc[s, "fq1"]
        s_dict["R"] = units.loc[s, "fq2"]
        trinity.append(s_dict)
    
    df = pd.DataFrame(trinity)
    df.to_csv(f"{outfile}", sep="\t", index=False, header=False)
    return None

if __name__ == "__main__":
    get_trinity_samples(sys.argv[1], sys.argv[2], sys.argv[3])