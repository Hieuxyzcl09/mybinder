FROM buildpack-deps:jammy

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    proot \
    wget \
    tar

# Tạo một thư mục làm việc
WORKDIR /home/jovyan

# Cài đặt jupyter
RUN pip3 install notebook

# Tải rootfs của Ubuntu 22.04
RUN wget http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz

# Giải nén rootfs
RUN mkdir ubuntu-rootfs && tar -xzf ubuntu-base-22.04-base-amd64.tar.gz -C ubuntu-rootfs

# Tạo script để khởi động proot với rootfs Ubuntu
RUN echo '#!/bin/bash\nproot -S ubuntu-rootfs /bin/bash' > start_ubuntu.sh && chmod +x start_ubuntu.sh

# Thiết lập command mặc định
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
