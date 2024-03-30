#!/bin/bash
#https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz
# 定义Tomcat和Java的版本
TOMCAT_VERSION=9.0.87
JAVA_VERSION=11

# 安装OpenJDK
echo "Installing OpenJDK-${JAVA_VERSION}..."
sudo yum install -y java-${JAVA_VERSION}-openjdk-devel

# 设置JAVA_HOME环境变量
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.bashrc
source ~/.bashrc

# 下载Tomcat
echo "Downloading Apache Tomcat ${TOMCAT_VERSION}..."
wget https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# 解压Tomcat
echo "Extracting Apache Tomcat..."
tar xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt

# 重命名Tomcat目录
sudo mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# 设置权限
sudo chmod +x /opt/tomcat/bin/*.sh

# 创建一个简单的systemd服务文件来管理Tomcat服务
echo "Creating Tomcat systemd service file..."
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=${JAVA_HOME}
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd，启用并启动Tomcat服务
echo "Starting Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

echo "Tomcat installation and setup completed."
