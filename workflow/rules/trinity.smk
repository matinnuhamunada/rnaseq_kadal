rule prep_trinity:
    output:
        "data/interim/trinity/{name}_{condition}_samples.txt"
    log:
        'logs/trinity/trinity-{name}_{condition}_samples.log'
    shell:
        """
        python workflow/scripts/prep_trinity.py {wildcards.name} {wildcards.condition} {output}
        """
rule trinity:
    input:
        "data/interim/trinity/{name}_{condition}_samples.txt"
    output:
        "data/processed/trinity/trinity_{name}-{condition}.Trinity.fasta"
    log:
        'logs/trinity/trinity-{name}-{condition}.log'
    params:
        normalize_max_read_cov = 30,
        min_kmer_cov = 2,
        SS_lib_type = "FR"
    conda:
        "../envs/trinity.yaml"
    threads: config["resources"]["trinity"]["threads"]
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_gb=config["resources"]["trinity"]["mem_gb"]
    shell:
        """
        Trinity --seqType fq --SS_lib_type {params.SS_lib_type}  --max_memory {resources.mem_gb} --CPU {threads} --samples_file {input} --output data/processed/trinity/trinity_{wildcards.name}-{wildcards.condition} \
        --min_kmer_cov {params.min_kmer_cov} --bflyCPU {threads} --bflyHeapSpaceMax {resources.mem_gb} --normalize_max_read_cov {params.normalize_max_read_cov} --trimmomatic
        """