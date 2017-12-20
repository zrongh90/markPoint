#!/bin/sh
echo "input database name:"
read dbName
db2 connect to $dbName > /dev/null 2>&1
appId=`db2 get snapshot for all on $dbName | grep -i "Appl id holding the oldest transaction" | cut -d'=' -f2`
if [ -z $appId"" ]
then
        echo "not application hold the transcations"
else
        echo "application ID $appId hold the transcations"
        db2 get snapshot for application agentid $appId

        echo "Force the application stop? y or n:"
        read action
        if [ $action = 'y' ]
        then
                echo "force the app $appId stop"
                db2 "force application ($appId)"
        else
                echo "not stop the applications $appId"
        fi
fi
db2 connect reset > /dev/null 2>&1
exit 0