dir=$(cd ../ && pwd)
docker run --rm -v $dir:/OS micahwagner/cross_compiler:latest bash -c 'cd OS/build/ && sh docker_script.sh'
#docker run -it --rm -v $dir:/OS micahwagner/cross_compiler:latest /bin/bash 