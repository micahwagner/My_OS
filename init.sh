#implement option to compile for mac or linux

OS=""

echo "Are you on MAC or LINUX (m/l)? "
read OS
cd build
sh init_docker.sh
if [ $OS = 'm' ] ; then  sh Bundler_MAC.sh ; fi
if [ $OS = 'l' ] ; then  sh Bundler_LINUX.sh  ; fi
cd ../

