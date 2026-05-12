file=$(realpath "$0")
# Absolute path to this folder
folder=$(dirname "$file")
# Karabiner requires symlinking the entire ~/.config/karabiner directory
ln -s "$folder" ~/.config
# restart karabiner server
# launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server
