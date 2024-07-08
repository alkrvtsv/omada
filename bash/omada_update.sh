#!/usr/bin/env bash

common() {
  sudo apt update
  sudo apt upgrade -y
}

omada_stop() {
  status=$(sudo tpeap status)
  if [[ "$status" =~ "already running" ]]; then
	echo "Контроллер выключается"
    sudo tpeap stop
	echo "Контроллер выключен"
  else
    echo "Контроллер выключен"
  fi
  
  sudo apt remove omadac -y
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

omada_update() {
  local latest_version="$1"
  local latest_url="$2"
  local filename="Omada_SDN_Controller_v${latest_version}_linux_x64.deb"

  echo "Загрузка версии $latest_version"
  wget -q "$latest_url" -O "$filename"
  if [[ $? -ne 0 ]]; then
    echo "Ошибка загрузки файла"
    return 1
  fi

  echo "Обновление до версии $latest_version"
  sudo dpkg -i "$filename"
  if [[ $? -ne 0 ]]; then
    echo "Ошибка установки"
    return 1
  fi
  echo "Контроллер обновлён до версии $latest_version"
}

common

omada_stop

read -r latest_version latest_url <<< "$(omada_links)"

omada_update "$latest_version" "$latest_url"

rm -rf Omada_SDN_Controller_v${latest_version}_linux_x64.deb