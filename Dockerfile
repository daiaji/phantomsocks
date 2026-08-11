# 第一阶段：编译
FROM golang:1.20-alpine AS builder

# 安装依赖
RUN apk add --no-cache git libpcap-dev gcc musl-dev linux-headers

WORKDIR /src
COPY . .

# 编译，输出名为 phantomsocks
RUN go build -v -tags rawsocket -ldflags "-s -w" -o phantomsocks .

# 第二阶段：运行环境
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache libpcap ca-certificates tzdata

# 1. 将二进制文件复制到系统 PATH 中，这样在任何目录都能执行
COPY --from=builder /src/phantomsocks /usr/bin/phantomsocks

# 2. 创建配置目录（虽然挂载会覆盖它，但这是好习惯）
RUN mkdir -p /etc/phantomsocks

# 3. 【关键修改】将工作目录设置为你的挂载点
# 这样程序运行时，会认为当前就在 /etc/phantomsocks 下
WORKDIR /etc/phantomsocks

# 暴露端口
EXPOSE 1080 5353 1681

# 启动命令
# 由于二进制在 /usr/bin，直接写名字即可
ENTRYPOINT ["phantomsocks"]

# 默认读取当前目录(即 /etc/phantomsocks) 下的 config.json
CMD ["-c", "config.json"]