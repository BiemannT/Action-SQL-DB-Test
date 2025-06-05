# SQL DB Test
This GitHub Action installs the tools `sqlcmd` and `sqlpackage` on the runner to test a Microsoft SQL-Server database based on a dacpac-file.

> [!NOTE]
> This action is only working on a linux runner.
>
> The intention of this action is to use it in conjunction with a service defined in the workflow file. Due to the limitation of the GitHub Runners, the service context is not available on windows or macos runners.

# Usage

```yml
- uses: BiemannT/Action-SQL-DB-Test@v1
  with:
    # REQUIRED
    # The password for the SQL-Server administrator login sa.
    sql-sa-pw: ''

    # OPTIONAL
    # The absolute path to the folder, where the dacpac-file is located.
    # If no path is given, the action will abort after the setup of the packages.
    sqlpackage-path: ''

    # OPTIONAL
    # The name of the database, which will be used for publishing of the dacpac-file on the SQL-Server.
    # Default: TestDB
    db-name: ''
```

> [!TIP]
> After the installation of the required packages, the commands `sqlcmd` and `sqlpackage` are provided in the `$GITHUB_PATH` variable and therefore can be executed from the command line directly.

This action will wait until the SQL-Server is ready to use. Then the dacpac-file will be published to the SQL-Server, if the variable `sqlpackage-path` is set and a dacpac-file is located in this path.

When the action is finished, the used dacpac-file can be used for further steps by using the output variable `package-file`.

# Example
The following example shows the usage of this action in a workflow file:

```yml
jobs:
  test:
    runs-on: ubuntu-latest

    env:
      DACPAC-PATH: ${{ github.workspace }}/build
      SQLPW: Test4Ever
      DBNAME: Test

    services:
      sql:
        image: mcr.microsoft.com/mssql/server:2017-latest
        # Alternative images:
        # SQL-Server 2019: mcr.microsoft.com/mssql/server:2019-latest
        # SQL-Server 2022: mcr.microsoft.com/mssql/server:2022-latest

        ports:
          - 1433:1433

        env:
          ACCEPT_EULA: Y
          MSSQL_PID: Express # Optional
          MSSQL_LCID: 1031 # German, adopt to your need
          MSSQL_MEMORY_LIMIT_MB: 1024
          MSSQL_SA_PASSWORD: ${{ env.SQLPW }}
          TZ: Europe/Berlin # Adopt timezone to your need

        steps:
          - name: build
            # Create or fetch the dacpac-file to the path given in the environment variable DACPAC-PATH.

          - name: Test Database
            uses: BiemannT/Action-SQL-DB-Test@v1
            id: testdb
            with:
              sql-sa-pw: ${{ env.SQLPW }}
              sqlpackage-path: ${{ env.DACPAC-PATH }}
              db-name: ${{ env.DBNAME }}

          - name: Further Test with dacpac-file
            run: ...
              # The used dacpac-file is available from the following variable: ${{ steps.testdb.outputs.package-file }}
```