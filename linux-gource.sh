#!/bin/bash

if [ ! -d ./linux ]; then
    echo "error: linux directory does not exist"
    echo -e "repository may have been cloned without loading submodule(s)\n"
    echo "please load the necessary submodule(s) with the following command:"
    echo -e "\n\tgit submodule update --init\n"
    exit 1
fi

if [ -s ./tags.log ]; then
    rm ./tags.log
fi

git -C ./linux log \
    --reverse \
    --pretty=format:"%ct|%s released" \
    | grep -P '(?<=\d{10}\|)Linux [\d\.]+ released$' > ./tags.log

gource \
    --caption-colour FFFF00 \
    --caption-file ./tags.log \
    --caption-offset 1 \
    --default-user-image ./assets/avatars/Tux.png \
    --hide mouse \
    --highlight-user "Linus Torvalds" \
    --logo ./assets/thelinuxfoundation.png \
    --output-framerate 60 \
    --output-ppm-stream ./linux-gource.ppm \
    --title "The Linux Kernel" \
    --user-image-dir ./assets/avatars \
    --user-scale 5 \
    --viewport 1920x1080 \
    ./linux

if [[ $? != 0 ]] || [ ! -s ./linux-gource.ppm ]; then
    exit 1
fi

ffmpeg \
    -y \
    -r 60 \
    -f image2pipe \
    -vcodec ppm \
    -i ./linux-gource.ppm \
    -vcodec libx264 \
    -preset medium \
    -pix_fmt yuv420p \
    -crf 1 \
    -threads 0 \
    -bf 0 \
    ./linux-gource.mp4
