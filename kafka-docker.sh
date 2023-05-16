#!/bin/bash

# Print the hostname of the server
echo "Executing script on $(hostname)

# Define the kafka version to install
read -p "Enter the Kafka version to install (press Enter for latest): " KAFKA_VERSION
KAFKA_VERSION="${KAFKA_VERSION:-latest}"

#!/bin/bash

# Define the kafka version to install
read -p "Enter the Kafka version to install (press Enter for latest): " KAFKA_VERSION
KAFKA_VERSION="${KAFKA_VERSION:-latest}"

# Define the variable for docker-compose file
DOCKER_COMPOSE_FILE=docker-compose.yml

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null
then
  echo "Docker Compose is not installed. Installing now..."
  echo payoda@123 | sudo -S curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  echo "Docker Compose has been successfully installed."
else
  echo "Docker Compose is already installed."
fi

# Provide Docker User Rights
echo payoda@123 | sudo -S chown root:docker /usr/local/bin/docker-compose
echo payoda@123 | sudo -S chmod +x /usr/local/bin/docker-compose

# Get the IP address of the current server
HOST_IP=$(hostname -I | awk '{print $1}')

# Create the Docker Compose file
cat << EOF > $DOCKER_COMPOSE_FILE
version: '3'
services:
  zoo1:
    image: confluentinc/cp-zookeeper:$KAFKA_VERSION
    hostname: zoo1
    container_name: zoo1
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_SERVER_ID: 1
      ZOOKEEPER_SERVERS: zoo1:2888:3888;zoo2:2888:3888;zoo3:2888:3888

  zoo2:
    image: confluentinc/cp-zookeeper:$KAFKA_VERSION
    hostname: zoo2
    container_name: zoo2
    ports:
      - "2182:2182"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2182
      ZOOKEEPER_SERVER_ID: 2
      ZOOKEEPER_SERVERS: zoo1:2888:3888;zoo2:2888:3888;zoo3:2888:3888

  zoo3:
    image: confluentinc/cp-zookeeper:$KAFKA_VERSION
    hostname: zoo3
    container_name: zoo3
    ports:
      - "2183:2183"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2183
      ZOOKEEPER_SERVER_ID: 3
      ZOOKEEPER_SERVERS: zoo1:2888:3888;zoo2:2888:3888;zoo3:2888:3888

  kafka1:
    image: confluentinc/cp-kafka:$KAFKA_VERSION
    hostname: kafka1
    container_name: kafka1
    ports:
      - "9092:9092"
      - "29092:29092"
    environment:
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka1:19092,EXTERNAL://${DOCKER_HOST_IP:-$HOST_IP}:9092,DOCKER://host.docker.internal:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,DOCKER:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2182,zoo3:2183"
      KAFKA_BROKER_ID: 1
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
      KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
      KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: "true"
    depends_on:
      - zoo1
      - zoo2
      - zoo3

  kafka2:
    image: confluentinc/cp-kafka:$KAFKA_VERSION
    hostname: kafka2
    container_name: kafka2
    ports:
      - "9093:9093"
      - "29093:29093"
    environment:
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka2:19093,EXTERNAL://${DOCKER_HOST_IP:-$HOST_IP}:9093,DOCKER://host.docker.internal:29093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,DOCKER:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2182,zoo3:2183"
      KAFKA_BROKER_ID: 2
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
      KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
      KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: "true"
    depends_on:
      - zoo1
      - zoo2
      - zoo3

  kafka3:
    image: confluentinc/cp-kafka:$KAFKA_VERSION
    hostname: kafka3
    container_name: kafka3
    ports:
      - "9094:9094"
      - "29094:29094"
    environment:
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka3:19094,EXTERNAL://${DOCKER_HOST_IP:-$HOST_IP}:9094,DOCKER://host.docker.internal:29094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,DOCKER:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181,zoo2:2182,zoo3:2183"
      KAFKA_BROKER_ID: 3
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
      KAFKA_AUTHORIZER_CLASS_NAME: kafka.security.authorizer.AclAuthorizer
      KAFKA_ALLOW_EVERYONE_IF_NO_ACL_FOUND: "true"
    depends_on:
      - zoo1
      - zoo2
      - zoo3
EOF

# Start Docker-Compose file
echo payoda@123 | sudo -S docker-compose up -d
