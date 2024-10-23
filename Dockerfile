FROM ubuntu:22.04

# 빌드 인자 정의 및 기본값 설정
ARG UID=1000

# 환경 변수 설정
ENV USERNAME=user

# 필수 패키지 설치
RUN apt-get update && apt install -y \
    wget \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    software-properties-common \
    sudo \
    git \
    libc++-dev libc++abi-dev \
    vim

# for gcc 14 
RUN apt install -y build-essential \
    unzip \
    flex \
    bison \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    zlib1g-dev \
    libisl-dev
# 작업 디렉토리 설정
WORKDIR /usr/src

# GCC 14 소스 코드 다운로드 및 압축 해제
RUN wget https://github.com/gcc-mirror/gcc/archive/refs/heads/releases/gcc-14.zip && \
    unzip gcc-14.zip && \
    rm gcc-14.zip

# 빌드 디렉토리 생성 및 이동
WORKDIR /usr/src/gcc-releases-gcc-14/build

# GCC 구성 설정, 빌드 및 설치
RUN ../configure --enable-languages=c,c++ --disable-multilib --prefix=/usr/local/gcc-14.0.0 && \
    make -j$(nproc) && \
    make install

# update-alternatives를 통해 gcc와 g++를 새로 설치한 버전으로 설정
RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-14.0.0/bin/gcc 200 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/local/gcc-14.0.0/bin/g++ 200

# LLVM apt 저장소 추가
RUN wget -O /usr/share/keyrings/llvm-archive-keyring.gpg https://apt.llvm.org/llvm-snapshot.gpg.key
RUN echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-16 main" > /etc/apt/sources.list.d/llvm.list
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | \
    gpg --dearmor | \
    tee /usr/share/keyrings/llvm-archive-keyring.gpg > /dev/null

# LLVM 16 설치
RUN apt-get update && apt install -y llvm-16 clang-16 libclang-16-dev #g++-14

# 패키지 설치 for har
RUN apt install -y protobuf-compiler pkg-config libxkbcommon-dev cmake ninja-build libgl-dev libgles-dev libwayland-dev libdbus-1-dev libgbm-dev libdrm-dev libssl-dev zlib1g-dev

# UID를 사용하여 사용자 추가
RUN useradd -m -u ${UID} ${USERNAME}

# sudo 권한 부여 (비밀번호 없이)
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

RUN apt install -y build-essential

# 사용자 변경
USER ${USERNAME}

# Rust 설치 (버전 1.75.0)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.75.0

# 작업 디렉토리 설정
WORKDIR /home/${USERNAME}

# 볼륨 마운트 지점 지정
#VOLUME /home/${USERNAME}/work

# 시작 스크립트 복사
COPY --chown=${UID}:${UID} start.sh /home/${USERNAME}/start.sh

# 시작 스크립트에 실행 권한 부여
RUN chmod +x /home/${USERNAME}/start.sh

# 컨테이너 시작 시 시작 스크립트 실행
#CMD ["/home/${USERNAME}/start.sh"]
CMD ["bash", "-c", "/home/${USERNAME}/start.sh"]
