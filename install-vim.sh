# Deps
sudo apt install ncurses-dev
sudo apt install make
sudo apt install build-essential

# Install from master
wget https://github.com/vim/vim/archive/master.zip
sudo apt install unzip
unzip master.zip

# Should install to /usr/local/bin/vim.
# Use ./configure --prefix=/path/to/install/vim to install somewhere else
cd vim-master
cd src/
./configure
make
sudo make install
