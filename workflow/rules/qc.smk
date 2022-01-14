# An example collection of Snakemake rules imported in the main Snakefile.
rule fastqc:
    input:
        lambda wildcards: get_pe_raw(wildcards.sample, wildcards.unit)
    output:
        html="data/interim/qc/fastqc/{sample}-{unit}.html",
        zip="data/interim/qc/fastqc/{sample}-{unit}_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: "--quiet"
    log:
        "workflow/report/logs/fastqc/{sample}-{unit}.log"
    threads: 1
    wrapper:
        "0.84.0/bio/fastqc"

rule multiqc:
    input:
        zip=expand("data/interim/qc/fastqc/{sample}-{unit}_fastqc.zip", sample=SAMPLES, unit=UNITS),
    output:
        "data/processed/qc/multiqc.html"
    params:
        ""  # Optional: extra parameters for multiqc.
    log:
        "workflow/report/logs/multiqc.log"
    conda:
        "../envs/utilities.yaml"
    shell:
        """
        multiqc --force -o data/processed/qc -n multiqc.html data/interim/qc/fastqc/  > {log} 2>&1
        """