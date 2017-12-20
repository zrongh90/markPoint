#!/bin/sh
#shell to config system's tivoli monitor, include lz,lo,21,11,ux
CURRENT_PWD=$(pwd)
target_hostname=$(hostname)
TIVOLI_CONFIG_PATH="/tivoli/opt/IBM/ITM/config"
TIVOLI_CONFIG_DATA_PATH=${TIVOLI_CONFIG_PATH}"/.ConfigData"

#copy config file to tivoli config path and restart the agent to turn on it
tivoli_config(){
        product=$1
        platform=$2
        src_config_file=${CURRENT_PWD}"/"${platform}"_k"${product}"env"
        dest_config_file=${TIVOLI_CONFIG_DATA_PATH}"/k"${product}"env"
        tmp_dest_config_file=${TIVOLI_CONFIG_DATA_PATH}"/k"${product}"env.tmp"
        case $product in
        "21"|"lz"|"ux"|"11")
                if [ -e ${src_config_file} ];then
                        #answer yes to cp, because alias cp="cp -i" in .bashrc
                        echo "yes" | cp -f ${src_config_file} ${dest_config_file}      
                        chmod 666 ${dest_config_file}
                        #change component 
                        component=$(echo | awk '{if(pl=="linux") print "lx8266";else print "aix525"}' pl="${platform}")
                        #sed -i "s/${component}|RUNNINGHOSTNAME|$/${component}|RUNNINGHOSTNAME|${target_hostname}|/g" ${dest_config_file}
                        trap "rm -f ${tmp_dest_config_file};exit 1" 0 1 2 3 13 15
                        sed "s/${component}|RUNNINGHOSTNAME|$/${component}|RUNNINGHOSTNAME|${target_hostname}|/g" ${dest_config_file} > ${tmp_dest_config_file}
                        trap "" 0 1 2 3 13 15
                        mv ${tmp_dest_config_file} ${dest_config_file}
                        /tivoli/opt/IBM/ITM/bin/itmcmd agent stop ${product}
                        /tivoli/opt/IBM/ITM/bin/itmcmd agent start ${product}
                fi
                ;;
        "lo")
                #lo_messages.cfg contains the log file config, such as linux.fmt,linux.conf,cpu precent
                component=$(echo | awk '{if(pl=="linux") print "messages";else print "errpt"}' pl="${platform}")
                src_component_file=${CURRENT_PWD}"/lo_"${component}".cfg"
                dest_component_file=${TIVOLI_CONFIG_PATH}'/'${target_hostname}"_lo_"${component}".cfg"
                if [ -e ${src_config_file} -a -e ${src_component_file} ];then
                        echo "yes" | cp ${src_config_file} ${dest_config_file} 
                        echo "yes" | cp ${src_component_file} ${dest_component_file}
                        chmod 666 ${dest_config_file}
                        chmod 666 ${dest_component_file}
                        #sed -i "s/${component}|RUNNINGHOSTNAME|$/${component}|RUNNINGHOSTNAME|${target_hostname}|/g" ${dest_config_file}
                        #sed -i "s/${component}|INSTANCE_ARG|$/${component}|INSTANCE_ARG|${target_hostname}'_${component}|'/g" ${dest_config_file}
                        trap "rm -f ${tmp_dest_config_file};exit 1" 0 1 2 3 13 15
                        #sed "s/${component}|RUNNINGHOSTNAME|$/${component}|RUNNINGHOSTNAME|${target_hostname}|/g" ${dest_config_file}
                        sed "s/${component}|INSTANCE_ARG|$/${component}|INSTANCE_ARG|${target_hostname}'_${component}|'/g" ${dest_config_file} > ${tmp_dest_config_file}
                        sed "s/${component}|RUNNINGHOSTNAME|$/${component}|RUNNINGHOSTNAME|${target_hostname}|/g" ${dest_config_file} > ${tmp_dest_config_file}
                        trap "" 0 1 2 3 13 15
                        mv ${tmp_dest_config_file} ${dest_config_file}
                        (sleep 2) | /tivoli/opt/IBM/ITM/bin/itmcmd config -o ${component} -A ${product}
                        /tivoli/opt/IBM/ITM/bin/itmcmd agent -o ${component} stop ${product}
                        /tivoli/opt/IBM/ITM/bin/itmcmd agent -o ${component} start ${product}
                fi
                ;;
        esac
}

sys_platform=$(echo $(uname) | tr '[A-Z]' '[a-z]')

if [ $sys_platform = "linux" ];then
        tivoli_config "lz" $sys_platform
        tivoli_config "21" $sys_platform
        tivoli_config "lo" $sys_platform
elif [ $sys_platform = "aix" ];then
        tivoli_config "ux" $sys_platform
        tivoli_config "11" $sys_platform
        tivoli_config "lo" $sys_platform
else
        echo "platform $sys_platform not know"
        exit 1
fi
