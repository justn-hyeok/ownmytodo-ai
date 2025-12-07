#!/bin/bash

set -e

echo "======================================"
echo "Docker 및 Docker Compose 설치 시작"
echo "======================================"

# Docker 설치 확인
if ! command -v docker &> /dev/null
then
    echo "Docker가 설치되어 있지 않습니다. Docker를 설치합니다..."
    
    # 기존 Docker 관련 패키지 제거
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # 필요한 패키지 설치
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Docker의 공식 GPG 키 추가
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Docker 저장소 설정
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Docker 설치
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 현재 사용자를 docker 그룹에 추가
    sudo usermod -aG docker $USER
    
    echo "Docker 설치 완료!"
else
    echo "Docker가 이미 설치되어 있습니다."
fi

# Docker Compose 플러그인 설치 확인
if ! docker compose version &> /dev/null
then
    echo "Docker Compose 플러그인이 설치되어 있지 않습니다. 설치합니다..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    echo "Docker Compose 플러그인 설치 완료!"
else
    echo "Docker Compose 플러그인이 이미 설치되어 있습니다."
fi

# Docker 서비스 시작
echo "Docker 서비스를 시작합니다..."
sudo systemctl start docker
sudo systemctl enable docker

# 버전 확인
echo ""
echo "======================================"
echo "설치된 버전 확인"
echo "======================================"
docker --version
docker compose version

# Docker Compose로 애플리케이션 실행
echo ""
echo "======================================"
echo "애플리케이션 실행 중..."
echo "======================================"
docker compose up -d

echo ""
echo "======================================"
echo "설치 및 실행 완료!"
echo "======================================"
echo "애플리케이션이 http://localhost:8000 에서 실행 중입니다."
echo "로그 확인: docker compose logs -f"
echo "중지: docker compose down"
echo ""
echo "참고: docker 그룹 권한을 적용하려면 로그아웃 후 재로그인이 필요할 수 있습니다."
