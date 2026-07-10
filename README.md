# CosyVoice Docker Compose 部署

## 文件说明

| 文件 | 用途 |
|------|------|
| `Dockerfile` | 基于 pytorch:2.3.1-cuda12.1 构建，自动克隆仓库 + 安装依赖 |
| `docker-compose.yml` | 默认 GPU 部署 |
| `docker-compose.cpu.yml` | CPU 专用覆盖文件 |
| `.env` | 环境变量（模型选择、端口） |

## 快速启动

### GPU 机器

```bash
# 1. 修改 .env 选模型
vim .env   # 改 MODEL_NAME

# 2. 链接模型目录（如果已有预下载模型）
mkdir -p models
ln -s /path/to/Fun-CosyVoice3-0.5B models/

# 3. 启动
docker compose up -d
```

### CPU 机器（本机 mac/linux 无 GPU）

```bash
docker compose -f docker-compose.yml -f docker-compose.cpu.yml up -d
```

## 模型下载

模型放在 `./models/` 目录下。三种方式：

### 方式一：容器自动下载（首次启动慢）
模型目录不存在时，代码里的 `AutoModel` 会自动从 ModelScope 拉取。

### 方式二：在宿主机预先下载（推荐）
```bash
pip install modelscope

# CosyVoice-300M（轻量，CPU 推荐）
python3 -c "from modelscope import snapshot_download; snapshot_download('iic/CosyVoice-300M', local_dir='./models/CosyVoice-300M')"

# CosyVoice2-0.5B
python3 -c "from modelscope import snapshot_download; snapshot_download('iic/CosyVoice2-0.5B', local_dir='./models/CosyVoice2-0.5B')"

# Fun-CosyVoice3-0.5B（最新，但 0.5B CPU 推理很慢）
python3 -c "from modelscope import snapshot_download; snapshot_download('FunAudioLLM/Fun-CosyVoice3-0.5B-2512', local_dir='./models/Fun-CosyVoice3-0.5B')"
```

### 方式三：HuggingFace（国外/代理）
```bash
HF_ENDPOINT=https://huggingface.co python3 -c "from huggingface_hub import snapshot_download; snapshot_download('FunAudioLLM/CosyVoice2-0.5B', local_dir='./models/CosyVoice2-0.5B')"
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MODEL_NAME` | `CosyVoice2-0.5B` | 模型目录名（相对于 pretrained_models） |
| `WEBUI_PORT` | `8000` | 对外端口 |
| `MODEL_ROOT` | `./models` | 宿主机模型根目录 |

## CPU vs GPU

| | CPU | GPU |
|------|-----|-----|
| 模型推荐 | CosyVoice-300M | CosyVoice2/3-0.5B |
| 推理速度 | 慢（一句话 10-30 秒） | 快（实时/流式） |
| Dockerfile 基镜像 | 同 GPU 镜像，自动检测无 CUDA 走 CPU | — |
| compose 命令 | `-f compose.yml -f compose.cpu.yml` | `-f compose.yml` |
