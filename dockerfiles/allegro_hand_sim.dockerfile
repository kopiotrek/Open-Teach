FROM ubuntu:20.04
ENTRYPOINT ["/bin/bash"]

# Set timezone environment variable to prevent interactive prompt
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install necessary packages
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y software-properties-common wget git curl

# Add the deadsnakes PPA to get Python 3.7
RUN add-apt-repository ppa:deadsnakes/ppa \
  && apt-get install -y python3.7 python3.7-venv python3.7-dev 

# Update alternatives to set Python 3.7 as the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Clone the GitHub repository
RUN git clone https://github.com/aadhithya14/Open-Teach.git

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && chmod +x Miniconda3-latest-Linux-x86_64.sh \
  && ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

# Install additional dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get install -y libgl1-mesa-glx libglib2.0-0 libusb-1.0-0

# Update PATH for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Create the Conda environment from the YAML file
RUN cd Open-Teach && conda env create -f env_isaac.yml

SHELL ["conda", "run", "-n", "openteach_isaac", "/bin/bash", "-c"]

# Cuda drivers installation
RUN DEBIAN_FRONTEND=noninteractive \
  && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && apt-get install -y nvidia-cuda-toolkit 


# Install Isaac Gym Preview 4
# Make sure to adjust the version and URL according to the latest version available
RUN wget https://developer.nvidia.com/isaac-gym-preview-4 \
  && tar -xzf isaac-gym-preview-4 \
  && rm isaac-gym-preview-4 \
  && mv isaacgym /opt/isaacgym

RUN source activate openteach_isaac \
  && cd /opt/isaacgym/python \
  && pip install -e . 


# Clean up
RUN rm -rf /var/lib/apt/lists/*
