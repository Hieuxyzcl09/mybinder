FROM ubuntu:22.04

# Cài đặt các gói cần thiết và dependencies của Docker
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    curl \
    sudo \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    iptables \
    libdevmapper1.02.1

# Cài đặt Docker từ file .deb
RUN curl -fsSL https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/containerd.io_1.6.9-1_amd64.deb -o containerd.io.deb && \
    curl -fsSL https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce-cli_20.10.21~3-0~ubuntu-jammy_amd64.deb -o docker-ce-cli.deb && \
    curl -fsSL https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce_20.10.21~3-0~ubuntu-jammy_amd64.deb -o docker-ce.deb && \
    dpkg -i containerd.io.deb && \
    dpkg -i docker-ce-cli.deb && \
    dpkg -i docker-ce.deb && \
    rm containerd.io.deb docker-ce-cli.deb docker-ce.deb

# Cài đặt tmate từ file .deb
RUN curl -fsSL https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz -o tmate.tar.xz && \
    tar -xvf tmate.tar.xz && \
    mv tmate-2.4.0-static-linux-amd64/tmate /usr/bin/ && \
    rm -rf tmate-2.4.0-static-linux-amd64 tmate.tar.xz

# Tạo một người dùng mới
RUN useradd -m hieuxyz && echo "hieuxyz ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hieuxyz

# Thêm người dùng vào nhóm docker
RUN usermod -aG docker hieuxyz

# Chuyển sang người dùng mới
USER hieuxyz
WORKDIR /home/hieuxyz

# Cài đặt Jupyter Notebook
RUN pip3 install notebook

# Tạo script khởi động
RUN echo '#!/bin/bash\n\
echo "Chào mừng đến với môi trường Ubuntu 22.04!"\n\
echo "Bạn đang chạy với quyền của người dùng $(whoami)"\n\
echo "Để sử dụng quyền sudo, hãy thêm sudo trước lệnh của bạn"\n\
echo "Docker đã được cài đặt. Để sử dụng, hãy thêm sudo trước lệnh docker"\n\
echo "tmate đã được cài đặt. Để sử dụng, chỉ cần gõ tmate"\n\
if ! pgrep dockerd > /dev/null; then\n\
    echo "Khởi động Docker daemon..."\n\
    sudo dockerd &\n\
fi\n\
bash\n\
' > start.sh && chmod +x start.sh

# Thiết lập command mặc định
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
