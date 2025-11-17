
#export IWREGISTRY=88.99.167.70:5000
#sudo docker buildx build   -t $IWREGISTRY/infoware/gitlab-ci-bookworm:latest   --cache-to=type=registry,ref=infoware/gitlab-ci-bookworm:buildcache,mode=max   --cache-from=type=registry,ref=infoware/gitlab-ci-bookworm:buildcache --load .
sudo docker buildx build   -t infoware/gitlab-ci-bookworm:latest   --cache-to=type=registry,ref=infoware/gitlab-ci-bookworm:buildcache,mode=max   --cache-from=type=registry,ref=infoware/gitlab-ci-bookworm:buildcache --push .
