FROM ubuntu:22.04
ENTRYPOINT ["/bin/bash"]
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y python3 git\
  && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/aadhithya14/Open-Teach.git
