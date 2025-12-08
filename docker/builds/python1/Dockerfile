FROM python0:latest

# Add more stuff
RUN pip install --no-cache-dir pandas numpy matplotlib
RUN apt-get update && apt-get install -y \
    net-tools \
    ninja-build \
    build-essential \
    openssl \
    traceroute \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

