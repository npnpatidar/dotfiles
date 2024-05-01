{ config
, ...
}:
{
  home.file.".scripts/distrobox.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash


      does_distrobox_exist() {
          distrobox-list | grep -q "$1"
      }

      echo "Checking for distrobox images..."

      if does_distrobox_exist "arch"; then
        echo "arch already exists"
      else
        echo "arch does not exist, creating..."
        distrobox-create --name arch --image quay.io/toolbx-images/archlinux-toolbox 
        distrobox enter --name arch -- sudo pacman -S --noconfirm git make gcc
        mkdir ${config.home.homeDirectory}/.tmpscript
        cd ${config.home.homeDirectory}/.tmpscript
        git clone https://aur.archlinux.org/yay.git
        cd yay
        distrobox enter --name arch -- makepkg -si --noconfirm
        cd ../..
        rm -rf ~/.tmpscript
        distrobox enter --name arch -- yay -Syyuu --noconfirm
        distrobox enter --name arch -- sudo pacman -S --noconfirm fzf eza fastfetch atuin zoxide
        distrobox enter --name arch -- yay -S --noconfirm noto-fonts-emoji nerd-fonts 
      fi

      if does_distrobox_exist "deb"; then
        echo "deb already exists"
      else
        echo "deb does not exist, creating..."
        distrobox-create --name deb --image quay.io/toolbx-images/debian-toolbox:12 
        distrobox enter --name deb -- bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
        distrobox enter --name deb -- sudo apt install fastfetch fzf zoxide 
        distrobox enter --name deb --sudo mkdir -p /etc/apt/keyrings
        distrobox enter --name deb -- wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        distrobox enter --name deb -- echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        distrobox enter --name deb -- sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        distrobox enter --name deb -- sudo apt update
        distrobox enter --name deb -- sudo apt install -y eza
      fi

    '';
  };
}

