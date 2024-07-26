FROM jupyter/base-notebook:python-3.9

USER root

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    sudo \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    iptables \
    libdevmapper1.02.1 \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh

# Cài đặt tmate
RUN curl -fsSL https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz -o tmate.tar.xz && \
    tar -xvf tmate.tar.xz && \
    mv tmate-2.4.0-static-linux-amd64/tmate /usr/bin/ && \
    rm -rf tmate-2.4.0-static-linux-amd64 tmate.tar.xz

# Tạo người dùng mới hieuxyz
RUN useradd -m -s /bin/bash hieuxyz && \
    echo "hieuxyz ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hieuxyz

# Thêm cả jovyan và hieuxyz vào nhóm docker
RUN usermod -aG docker jovyan && \
    usermod -aG docker hieuxyz

# Cài đặt các gói Python bổ sung
RUN pip install --no-cache-dir \
    jupyterlab \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn

# Tạo script khởi động
RUN echo '#!/bin/bash\n\
echo "Chào mừng đến với môi trường Jupyter!"\n\
echo "Bạn đang chạy với quyền của người dùng $(whoami)"\n\
echo "Để chuyển sang người dùng hieuxyz, hãy chạy: sudo -u hieuxyz -i"\n\
echo "Để sử dụng quyền sudo, hãy thêm sudo trước lệnh của bạn"\n\
echo "Docker đã được cài đặt. Để sử dụng, hãy thêm sudo trước lệnh docker"\n\
echo "tmate đã được cài đặt. Để sử dụng, chỉ cần gõ tmate"\n\
if ! pgrep dockerd > /dev/null; then\n\
    echo "Khởi động Docker daemon..."\n\
    sudo dockerd &\n\
fi\n\
exec "$@"\n\
' > /usr/local/bin/start-notebook.sh && chmod +x /usr/local/bin/start-notebook.sh

# Cấp quyền cho jovyan sử dụng sudo để chuyển sang hieuxyz
RUN echo "jovyan ALL=(hieuxyz) NOPASSWD: /bin/bash" >> /etc/sudoers.d/jovyan

# Chuyển về người dùng jovyan
USER jovyan

# Thiết lập command mặc định
CMD ["/usr/local/bin/start-notebook.sh", "jupyter", "lab", "--ip", "0.0.0.0"]
