#!/bin/bash

echo "::group::Install dacpac-file"

# Check if the given folder exists
if [ -d "$DACPATH" ]
then

    # Search the dacpac-file in this folder
    DACFILE=$(find $DACPATH -type f -name "*.dacpac")

    if [ -e ${DACFILE[0]} ]
    then
        echo "Use dacpac-file: \"${DACFILE[0]}\""
        echo "FILE=${DACFILE[0]}" >> "$GITHUB_OUTPUT"

        # Publish dacpac-file to the SQL-Server
        sqlpackage /Action:Publish \
            /SourceFile:"${DACFILE[0]}" \
            /TargetDatabaseName:"$DBNAME" \
            /TargetPassword:"$SQLPW" \
            /TargetServerName:"localhost" \
            /TargetTrustServerCertificate:"True" \
            /TargetUser:"sa" \
            /p:DropObjectsNotInSource="True" \
            /p:DropPermissionsNotInSource="True" \
            /p:RegisterDataTierApplication="True"

        echo "Dacpac-file successfully published to the SQL-Server."

    else
        echo "No dacpac-file located in the given folder!"
        exit 101
    fi

else
    echo "The given folder \"$DACPATH\" does not exist!"
    exit 100
fi

echo "::endgroup::"