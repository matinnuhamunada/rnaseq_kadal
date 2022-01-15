rule trinity:
    input:
        left="data/interim/trimmed/{sample}-{unit}.1.fastq.gz",
        right="data/interim/trimmed/{sample}-{unit}.2.fastq.gz",
    output:
        "data/processed/trinity/trinity_{sample}-{unit}.Trinity.fasta"
    log:
        'logs/trinity/trinity-{sample}-{unit}.log'
    params:
        normalize_max_read_cov = 30,
        min_kmer_cov = 2,
        SS_lib_type = "FR"
    conda:
        "../envs/trinity.yaml"
    threads: 2
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_gb="2G"
    shell:
        """
        Trinity --seqType fq --SS_lib_type {params.SS_lib_type}  --max_memory {resources.mem_gb} --CPU {threads} --left {input.left} --right {input.right} --output data/processed/trinity/trinity_{wildcards.sample}-{wildcards.unit} \
        --min_kmer_cov {params.min_kmer_cov} --bflyCPU {threads} --bflyHeapSpaceMax {resources.mem_gb} --normalize_max_read_cov {params.normalize_max_read_cov}
        """