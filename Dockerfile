FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# 1. apt 系统依赖
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3.10 python3.10-dev python3-pip \
        git git-lfs build-essential curl wget \
        ffmpeg sox libsox-dev unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# 2. pip 工具链 + numpy + PyTorch CPU（合一层减少冗余 RUN）
RUN python3 -m pip install --upgrade pip setuptools wheel numpy==1.26.4 \
    -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com \
    && pip install torch==2.3.1 torchaudio==2.3.1 \
    -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com

# 3. requirements.txt
WORKDIR /workspace/CosyVoice
COPY requirements.txt .
RUN pip install -r requirements.txt --no-build-isolation \
    -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com

# 4. 源码
COPY . .
ENV PYTHONPATH="/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS:${PYTHONPATH}"

ENV WEBUI_PORT=8000
ENV MODEL_DIR=pretrained_models/CosyVoice-300M
EXPOSE ${WEBUI_PORT}

CMD ["python3", "webui.py", "--port", "8000", "--model_dir", "pretrained_models/CosyVoice-300M"]
