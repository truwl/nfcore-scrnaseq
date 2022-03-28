version 1.0

workflow scrnaseq {
	input{
		String? reads
		String? input_paths
		String outdir = "./results"
		String? email
		String type = "10x"
		String chemistry = "V3"
		String? barcode_whitelist
		String aligner = "alevin"
		String? genome
		File? fasta
		String igenomes_base = "s3://ngi-igenomes/igenomes/"
		Boolean? igenomes_ignore
		String? transcript_fasta
		String? gtf
		String? save_reference
		String? salmon_index
		String? txp2gene
		String? star_index
		String? kallisto_gene_map
		Boolean? bustools_correct
		Boolean? skip_bustools
		String? kallisto_index
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			reads = reads,
			input_paths = input_paths,
			outdir = outdir,
			email = email,
			type = type,
			chemistry = chemistry,
			barcode_whitelist = barcode_whitelist,
			aligner = aligner,
			genome = genome,
			fasta = fasta,
			igenomes_base = igenomes_base,
			igenomes_ignore = igenomes_ignore,
			transcript_fasta = transcript_fasta,
			gtf = gtf,
			save_reference = save_reference,
			salmon_index = salmon_index,
			txp2gene = txp2gene,
			star_index = star_index,
			kallisto_gene_map = kallisto_gene_map,
			bustools_correct = bustools_correct,
			skip_bustools = skip_bustools,
			kallisto_index = kallisto_index,
			help = help,
			publish_dir_mode = publish_dir_mode,
			validate_params = validate_params,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			show_hidden_params = show_hidden_params,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-scrnaseq/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		String? reads
		String? input_paths
		String outdir = "./results"
		String? email
		String type = "10x"
		String chemistry = "V3"
		String? barcode_whitelist
		String aligner = "alevin"
		String? genome
		File? fasta
		String igenomes_base = "s3://ngi-igenomes/igenomes/"
		Boolean? igenomes_ignore
		String? transcript_fasta
		String? gtf
		String? save_reference
		String? salmon_index
		String? txp2gene
		String? star_index
		String? kallisto_gene_map
		Boolean? bustools_correct
		Boolean? skip_bustools
		String? kallisto_index
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /scrnaseq-1.1.0  -profile truwl,nfcore_scrnaseq 	~{"--reads '" + reads + "'"}	~{"--input_paths '" + input_paths + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--type '" + type + "'"}	~{"--chemistry '" + chemistry + "'"}	~{"--barcode_whitelist '" + barcode_whitelist + "'"}	~{"--aligner '" + aligner + "'"}	~{"--genome '" + genome + "'"}	~{"--fasta '" + fasta + "'"}	~{"--igenomes_base '" + igenomes_base + "'"}	~{true="--igenomes_ignore  " false="" igenomes_ignore}	~{"--transcript_fasta '" + transcript_fasta + "'"}	~{"--gtf '" + gtf + "'"}	~{"--save_reference '" + save_reference + "'"}	~{"--salmon_index '" + salmon_index + "'"}	~{"--txp2gene '" + txp2gene + "'"}	~{"--star_index '" + star_index + "'"}	~{"--kallisto_gene_map '" + kallisto_gene_map + "'"}	~{true="--bustools_correct  " false="" bustools_correct}	~{true="--skip_bustools  " false="" skip_bustools}	~{"--kallisto_index '" + kallisto_index + "'"}	~{true="--help  " false="" help}	~{"--publish_dir_mode '" + publish_dir_mode + "'"}	~{true="--validate_params  " false="" validate_params}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{"--custom_config_version '" + custom_config_version + "'"}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--hostnames '" + hostnames + "'"}	~{"--config_profile_name '" + config_profile_name + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-scrnaseq:1.1.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    