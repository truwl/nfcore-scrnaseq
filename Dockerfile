FROM debian:bullseye
RUN apt-get update && apt-get install -y wget default-jre procps
COPY truwl.nf.config truwl.nf.config
RUN wget https://github.com/nf-core/scrnaseq/archive/refs/tags/1.1.0.tar.gz
RUN tar -xvf 1.1.0.tar.gz
RUN wget -qO- https://get.nextflow.io | bash
        