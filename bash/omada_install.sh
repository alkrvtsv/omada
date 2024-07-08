#!/usr/bin/env bash

common() {
  sudo apt update
  sudo apt upgrade -y
}

requirements() {
  sudo apt-get install jsvc -y
  sudo apt-get install openjdk-11-jdk -y
  sudo mkdir /usr/lib/jvm/java-11-openjdk-amd64/lib/amd64
  sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64/lib/server /usr/lib/jvm/java-11-openjdk-amd64/lib/amd64/
}

mongo_install() {
  wget https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/4.4/multiverse/binary-amd64/mongodb-org-server_4.4.27_amd64.deb
  sudo dpkg -i mongodb-org-server_4.4.27_amd64.deb
}

omada_links() {
  url="https://www.tp-link.com/us/support/download/omada-software-controller/"

  html=$(curl -fsSL "$url")
  if [[ $? -ne 0 ]]; then
    echo "Ошибка загрузки страницы"
    exit 1
  fi

  regex='https://.*x64.deb'
  latest_url=$(echo "$html" | grep -o "$regex" | head -n1)

  if [[ -z "$latest_url" ]]; then
    echo "Ссылка не найдена"
    exit 1
  fi

  regex='.*_v([0-9.]+)_'
  [[ "$latest_url" =~ $regex ]]
  latest_version="${BASH_REMATCH[1]}"
  
  echo "$latest_version $latest_url"
}

omada_install(){
  local latest_version="$1"
  local latest_url="$2"
  local filename="Omada_SDN_Controller_v${latest_version}_linux_x64.deb"

  echo "Загрузка версии $latest_version"
  wget -q "$latest_url" -O "$filename"
  if [[ $? -ne 0 ]]; then
    echo "Ошибка загрузки файла"
    return 1
  fi

  echo "Установка версии $latest_version"
  sudo dpkg -i "$filename"
  if [[ $? -ne 0 ]]; then
    echo "Ошибка установки"
    return 1
  fi
  echo "Установлен контроллер версии $latest_version"
}


common

requirements

mongo_install

read -r latest_version latest_url <<< "$(omada_links)"

omada_install "$latest_version" "$latest_url"

rm -rf Omada_SDN_Controller_v${latest_version}_linux_x64.deb mongodb-org-*.deb