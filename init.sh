#implement option to compile for mac or linux

cd build
sh init_docker.sh
sh Bundler_MAC.sh
cd ../
bochs -f BochsConfig.txt