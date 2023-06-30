#!/usr/bin/env bash

mv "$HOME/settings/*" "$HOME/.config"

wget https://github.com/SL33PZ/cfgs/settings/zshrc -O "$HOME/.zshrc"

sh -c "$(wget https://github.com/SL33PZ/yay.bsx -O -)";

wget https://github.com/SL33PZ/cfgs/pkglist.txt -O "$HOME/Downloads/pkglist.txt"
cd "$HOME/Downloads" && yay -S --needed --noconfirm --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu --noredownload --skippgpcheck --nouseask - < pkglist.txt

mv "$HOME/.bashrc.backup" "$HOME/.bashrc"
