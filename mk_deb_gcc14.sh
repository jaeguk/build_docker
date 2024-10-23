#sudo checkinstall --pkgname=gcc-14.2.1 --pkgversion="14.2.1" --backup=no --deldoc=yes --fstrans=no --default

sudo apt install -y ruby ruby-dev
sudo gem install --no-document fpm

sudo mkdir -p /usr/src/gcc-releases-gcc-14/deb/usr/local
sudo cp -arf /usr/local/gcc-14.0.0 /usr/src/gcc-releases-gcc-14/deb/usr/local
sudo fpm -s dir -t deb -n gcc-14.2.1 -v 14.2.1 ./usr/local/gcc-14.0.0/=/usr/local/gcc-14.0.0
