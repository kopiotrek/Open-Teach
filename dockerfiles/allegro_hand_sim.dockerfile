FROM ubuntu:20.04
ENTRYPOINT ["/bin/bash"]

# Set timezone environment variable to prevent interactive prompt
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install necessary packages
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y software-properties-common wget git

# Add the deadsnakes PPA to get Python 3.9
RUN add-apt-repository ppa:deadsnakes/ppa \
  && apt-get update \
  && apt-get install -y python3.9 python3.9-venv python3.9-dev

# Update alternatives to set Python 3.9 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Clone the GitHub repository
RUN git clone https://github.com/aadhithya14/Open-Teach.git

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && chmod +x Miniconda3-latest-Linux-x86_64.sh \
  && ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

# Update PATH for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Create the Conda environment from the YAML file
RUN cd Open-Teach && conda env create -f env_isaac.yml
RUN conda run -n openteach_isaac

# # Install additional dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get install -y libgl1-mesa-glx libglib2.0-0 libusb-1.0-0

# RUN DEBIAN_FRONTEND=noninteractive \
#   conda install -y -c conda-forge pyrealsense2

# RUN DEBIAN_FRONTEND=noninteractive \
#   && pip install shapely ikpy

# Install Isaac Gym Preview 4
# Make sure to adjust the version and URL according to the latest version available
RUN wget https://developer.nvidia.com/isaac-gym-preview-4 \
  && tar -xzf isaac-gym-preview-4 \
  && rm isaac-gym-preview-4 \
  && mv isaacgym /opt/isaacgym

# RUN DEBIAN_FRONTEND=noninteractive \
#   && pip install gym matplotlib


# Clean up
RUN rm -rf /var/lib/apt/lists/*
