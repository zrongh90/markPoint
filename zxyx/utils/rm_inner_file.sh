#!/bin/sh
rm_inner_file(){
        rm_path=$1
        if [ -e $rm_path ]
        then
                cd $rm_path
                find . -type f -exec rm '{}' \;
        fi
}
