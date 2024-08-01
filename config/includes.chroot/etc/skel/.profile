#xfconf-query --create --channel xfce4-session --property /general/StartAssistiveTechnologies --type bool --set true
gsettings set org.gnome.desktop.interface toolkit-accessibility true 
gsettings set org.onboard start-minimized true
gsettings set org.onboard.auto-show enabled true
gsettings set org.onboard.window docking-enabled true
gsettings set org.onboard.window.landscape dock-expand false
gsettings set org.onboard.window docking-shrink-workarea false
gsettings set org.onboard.auto-show tablet-mode-detection-enabled false
gsettings set org.onboard.auto-show hide-on-key-press false
#custom look and feel
gsettings set org.onboard.window transparency 10
gsettings set org.onboard layout '/usr/share/onboard/layouts/Small.onboard'
gsettings set org.onboard theme '~/.local/share/onboard/themes/Nightshade.theme'
gsettings set org.onboard.theme-settings color-scheme '/usr/share/onboard/themes/Charcoal.colors'
gsettings set org.onboard.theme-settings key-style 'flat'
gsettings set org.onboard.theme-settings roundrect-radius 0
gsettings set org.onboard.theme-settings key-label-font 'Sans'

