#!/bin/bash
prf_path=$1
srv_name=$2
was_usr=$(ps -ef | grep -v grep | grep -v call_py_getjc | grep ${prf_path} | grep ${srv_name} | awk '{print $1}')
if [ ! -z $was_usr ];then
    su - $was_usr -c "python /zxyx/utils/py_getjc.py ${prf_path} ${srv_name}"
else
    echo "get server information error, not this server"
fi
