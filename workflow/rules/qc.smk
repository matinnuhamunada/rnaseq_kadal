# An example collection of Snakemake rules imported in the main Snakefile.
rule fastqc:
    input:
        lambda wildcards: get_pe_raw(wildcards.sample)
    output:
        html="data/interim/qc/fastqc/{sample}.html",
        zip="data/interim/qc/fastqc/{sample}_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: "--quiet"
    log:
        "workflow/report/logs/fastqc/{sample}-.log"
    threads: config["resources"]["fastqc"]["threads"]
    wrapper:
        "v0.85.1/bio/fastqc"

rule trimmomatic_pe:
    input:
        r1=lambda wildcards: get_pe_raw(wildcards.sample)[0],
        r2=lambda wildcards: get_pe_raw(wildcards.sample)[1],
    output:
        r1="data/interim/trimmed/{sample}-.1.fastq.gz",
        r2="data/interim/trimmed/{sample}-.2.fastq.gz",
        # reads where trimming entirely removed the mate
        r1_unpaired="data/interim/trimmed/{sample}-.1.unpaired.fastq.gz",
        r2_unpaired="data/interim/trimmed/{sample}-.2.unpaired.fastq.gz",
    log:
        "workflow/report/logs/trimmomatic/{sample}-.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads:
        config["resources"]["trimmomatic"]["threads"]
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=config["resources"]["trimmomatic"]["mem_mb"]
    wrapper:
        "v0.85.1/bio/trimmomatic/pe"

rule multiqc:
    input:
        zip=expand("data/interim/qc/fastqc/{sample}_fastqc.zip", sample=SAMPLES),
        trinity=expand("data/processed/trinity/trinity_{name}-{condition}.Trinity.fasta", name=run_name, condition=CONDITIONS)
    output:
        "data/processed/qc/multiqc.html"
    params:
        fastqc_dir="data/interim/qc/fastqc/",
        trinity_dir=expand("data/processed/trinity/trinity_{name}-{condition}/", name=run_name, condition=CONDITIONS)
    log:
        "workflow/report/logs/multiqc.log"
    conda:
        "../envs/utilities.yaml"
    shell:
        """
        multiqc --force -o data/processed/qc -n multiqc.html {params.fastqc_dir} {params.trinity_dir}> {log} 2>&1
        """

rule run_busco:
    input:
        "data/processed/trinity/trinity_{name}-{condition}.Trinity.fasta"
    output:
        directory("data/processed/busco/txome_busco_{name}-{condition}")
    log:
        "workflow/report/logs/quality/transcriptome_busco_{name}-{condition}.log"
    threads: 8
    params:
        mode="transcriptome",
        lineage="tetrapoda_odb10",
        downloads_path="resources/busco_downloads",
        # optional parameters
        extra=""
    wrapper:
        "v0.85.1/bio/busco"