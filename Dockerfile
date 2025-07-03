# --- 阶段 1: 构建器 ---
# 使用一个标准的Python镜像作为构建环境
FROM python:3.11-slim as builder

# 设置工作目录
WORKDIR /install

# 复制依赖定义文件
COPY requirements.txt .

# 安装依赖项到一个独立的目录中，而不是系统目录
# 这使得在下一阶段复制它们变得非常容易和干净
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# --- 阶段 2: 最终镜像 ---
# 从一个非常小的、干净的Python镜像开始
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 从“构建器”阶段复制已经安装好的依赖库
COPY --from=builder /install /usr/local

# 只复制运行应用所必需的核心代码
COPY ./app ./app

# 设置Hugging Face Spaces等平台需要的环境变量
ENV PORT=7860
ENV HOST=0.0.0.0

# 暴露端口
EXPOSE 7860

# 容器启动时运行的命令
# 确保启动命令与项目结构匹配
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
