FROM debian:bullseye
RUN apt-get update && apt-get install -y wget default-jre procps
RUN wget https://raw.githubusercontent.com/truwl/nfcore-config/a619baab639ecd6fe7fe196cb848c80793cb57fd/truwl.nf.config
RUN wget https://github.com/nf-core/scrnaseq/archive/refs/tags/1.1.0.tar.gz
RUN tar -xvf 1.1.0.tar.gz
RUN wget -qO- https://get.nextflow.io | bash
        