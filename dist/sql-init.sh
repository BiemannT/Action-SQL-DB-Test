#!/bin/bash

# Install Sqlcmd
echo "::group::Install sqlcmd"

if [ -f "/opt/mssql-tools18/bin/sqlcmd" ]
then
    echo "Sqlcmd already installed."

else
    sudo apt-get update
    sudo apt-get -y -q install mssql-tools18 unixodbc-dev
    echo "/opt/mssql-tools18/bin" >> "$GITHUB_PATH"
    echo "Sqlcmd installed."
fi

echo "::endgroup::"

# Install SqlPackage
echo "::group::Install SqlPackage"

if [ -f "/opt/sqlpackage/sqlpackage" ]
then
    echo "SqlPackage already installed."

else
    wget https://aka.ms/sqlpackage-linux -q -O sqlpackage.zip
    unzip -qq sqlpackage.zip -d "/opt/sqlpackage"
    chmod a+x "/opt/sqlpackage/sqlpackage"
    echo "/opt/sqlpackage" >> "$GITHUB_PATH"
    rm sqlpackage.zip
    echo "SqlPackage installed."
fi

echo "::endgroup::"

echo "::group::Wait for initialization of the SQL-Server"

DBSTATUS=1
ERRCODE=1
i=0

while [ $DBSTATUS -ne 0 ] && [ $i -lt 60 ] && [ $ERRCODE -ne 0 ]
do
    i=$(expr $i + 1)
    DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -S localhost -h -1 -t 1 -C -U sa -P "$SQLPW" -Q "SET NOCOUNT ON; SELECT SUM(state) FROM sys.databases")
    ERRCODE=$?
    echo "SQL-Server state: $DBSTATUS"
    sleep 1
done

if [ $DBSTATUS -ne 0 ] || [ $ERRCODE -ne 0 ]
then
    echo "The SQL-Server is not ready after 60 seconds, or one or more databases are not online."
    exit 2
else
    echo "The SQL-Server is ready to execute commands."
fi

echo "::endgroup::"