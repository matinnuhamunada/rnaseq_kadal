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
        "v0.85.1/bio/fastqc"

rule trimmomatic_pe:
    input:
        r1=lambda wildcards: get_pe_raw(wildcards.sample, wildcards.unit)[0],
        r2=lambda wildcards: get_pe_raw(wildcards.sample, wildcards.unit)[1],
    output:
        r1="data/interim/trimmed/{sample}-{unit}.1.fastq.gz",
        r2="data/interim/trimmed/{sample}-{unit}.2.fastq.gz",
        # reads where trimming entirely removed the mate
        r1_unpaired="data/interim/trimmed/{sample}-{unit}.1.unpaired.fastq.gz",
        r2_unpaired="data/interim/trimmed/{sample}-{unit}.2.unpaired.fastq.gz",
    log:
        "workflow/report/logs/trimmomatic/{sample}-{unit}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads:
        8
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "v0.85.1/bio/trimmomatic/pe"

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