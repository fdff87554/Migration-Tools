# Liquibase
* 此紀錄為紀錄 Liquibase 的使用方法，並且說明如何使用 Liquibase 來管理資料庫的變更。
> * 本文件操作環境為 OS: ubuntu 22.04 server / Database: 10.6.12-MariaDB-0ubuntu0.22.04.1 / Liquibase: 4.20.0


## Overview / 概述
* Liquibase 是一個開源的資料庫變更管理工具，它可以讓你在資料庫上執行變更，並且可以讓你在任何時間點回到任何一個變更的狀態。
* Liquibase 有幾個核心文件，其分別為
  * `liquibase.properties` - 一個用來記錄 Liquibase 的基本設定的檔案
  * `changelog.<type>` - 一個用來撰寫變更的檔案，有四種不同的檔案格式可以使用，分別是 `xml`、`json`、`yaml`、`sql`。
    > 會比較推薦 `xml` 跟 `yaml` 檔案，但 `sql` 檔案跟資料庫互動比較直觀，所以也推薦使用 `sql` 檔案。
* Liquibase 還有其他文件，但其並非核心必要文件，我們可以先跳過。


## Installation / 安裝
* Liquibase 在使用的過程中會需要 `java` 環境，所以在安裝 Liquibase 之前，請先確認你的系統有安裝 `java`。
* 安裝 Liquibase 的流程有些複雜，且不同的作業系統安裝方式也不同，這邊先準備了一份 `Debian / Ubuntu` 的安裝 shell script，可以直接執行 `debain_ubuntu.sh` 來安裝 Liquibase。
  > * 相關安裝說明請參考 `debain_ubuntu.sh` 的註解。

## Usage / 使用
* 要使用 Liquibase 來管理資料庫的變更，我們需要先準備好 `liquibase.properties` 跟 `changelog.<type>` 這兩個文件。
* 其中 `liquibase.properties` 是用來記錄 Liquibase 的基本設定，而 `changelog.<type>` 則是用來記錄資料庫變更的文件。

### Setup liquibase.properties / 設定 liquibase.properties
* 要管理資料庫的更變，理論上本來就需要告訴工具你的資料庫資訊，包含
  * 要操作的資料庫管理工具
  * 要操作的資料庫
  * 要使用的操作使用者名稱
  * 要使用的操作使用者密碼
  * 我們操作的資料庫行為的檔案
* 那 Liquibase 也是一樣，我們需要告訴 Liquibase 這些資訊，所以我們需要準備一個 `liquibase.properties` 來記錄這些資訊。
* 在 `liquibase.properties` 這份檔案中，
  * `changeLogFile` - 記錄我們操作的資料庫行為的檔案，這個檔案會在後面的章節中說明。
  * `liquibase.command.url` - 要操作的資料庫，他會是一個 `jdbc` 的連結。
  * `liquibase.command.username` - 要使用的操作使用者名稱。
  * `liquibase.command.password` - 要使用的操作使用者密碼。
* 有上述這些資訊後，我們就可以開始使用 Liquibase 來管理資料庫的變更了，而有些其他的設定可以幫我們做到一些比較，分別有
  * `liquibase.command.referenceUrl` - 要比較的資料庫，他會是一個 `jdbc` 的連結，當使用 `diff/diffchangelog` 指令時，會用來比較兩個資料庫的差異。
  * `liquibase.command.referenceUsername` - 要比較的資料庫的使用者名稱。
  * `liquibase.command.referencePassword` - 要比較的資料庫的使用者密碼。
* 有上述所有的設定後，基本上 Liquibase 的相關 commands 都可以使用了。

### Setup changelog.<type> / 設定 changelog.<type>
* `changelog.<type>` 是用來記錄資料庫變更的文件，他可以是 `xml`、`json`、`yaml`、`sql` 這四種不同的格式。
* 這邊我們先使用 `sql` 作為範例，因為在撰寫 `sql` 的時候會直接對其一般的 `sql` 有比較好的理解，但請注意，我個人建議可以使用 `yaml` 來撰寫。
* 由於會有多個版本的 `changelog.<type>` 檔案，Liquibase 一個建議的目錄結構來存放這些對應的操作文件，其如下，
    > ```markdown=
    > └── <DBMS>
    >     └── changelog
    >         └── <dbms>.changelog-<version>.<type>
    > ```
* Example:
    > ```markdown=
    > └── mariadb
    >     └── changelog
    >         ├── mariadb.changelog-init.yml
    >         ├── mariadb.changelog-1_0.yml
    >         └── ...
    > ```

### Write changeset / 寫變更
* `changeset` 是我們用來記錄關於資料庫變更的單位，所有我們希望資料庫做的變更都會被紀錄成一組 `changeset`。
* 每一個 `changeset` 由 `id`、`author`、`changes` 這三個部分組成，其中 `id` 跟 `author` 組成對於 changeset 的唯一識別符號。
  * 請注意，`id` 只是一個識別符號，並不代表運行順序，也不一定要是整數。
  * 運行的前後關聯性依據為 `preconditions`、`contexts`、`labels` 和其他屬性來運行。
* Examples:
  * SQL:
    ```sql=
    --changeset test_name:1
    create table company (
      id int primary key,
      address varchar(255)
    );
    ```
  * YAML:
    ```yaml=
    databaseChangeLog:
      - changeSet:
        id: 1
        author: test_name
        changes:
          - createTable:
              tableName: company
              columns:
                - column:
                    name: id
                    type: int
                    constraints:
                      primaryKey: true
                      nullable: false
                - column:
                    name: address
                    type: varchar(255)
                    constraints:
                      nullable: false
    ```
* Refs:
  * https://docs.liquibase.com/concepts/changelogs/changeset.html
  * https://docs.liquibase.com/concepts/changelogs/preconditions.html
  * https://docs.liquibase.com/concepts/changelogs/attributes/contexts.html
  * https://docs.liquibase.com/concepts/changelogs/attributes/labels.html
  * https://docs.liquibase.com/concepts/changelogs/sql-format.html

## Workflow / 工作流程
* Step 1: Create a changelog / 建立一個 changelog
  * 依照上面的說明，在目錄結構中，我們需要建立一個 `changelog` 的目錄，並且在裡面建立一個 `changelog.<type>` 的文件。
* Step 2: Add your changesets to a changelog / 將你的變更加入到 changelog 中
  * 在 `changelog.<type>` 中，加入對應的 `changeset` 操作。
* Step 3: Verify the SQL that you will execute / 驗證你將要執行的 SQL
  * 利用 `updateSQL` 指令，可以驗證你將要執行的 SQL。
* Step 4: Save your changelog to your source control / 將你的 changelog 儲存到你的 source control
  * 利用 git 等 source control 工具，將你的 `changelog.<type>` 儲存起來。
* Step 5: Run the database update command / 執行資料庫更新的指令
  * 利用 `update` 指令，執行你的 `changelog.<type>`，並且將變更寫入到資料庫中。
* Step 6: Verify that the changeset or changesets were executed / 驗證變更是否被執行
  * 可以利用 `history` 指令，來查看已經被執行的 changesets。
  * 可以利用 `status` 指令，來查看尚未被執行的 changesets。
  * 可以利用 `diff` 指令，來查看兩個資料庫之間的差異。
  * 直接訪問 DBMS，查看資料庫的變更。

## Commands / 指令
* `generateChangeLog` / 產生變更日誌
  * 產生變更日誌，並且將變更寫入到資料庫中。
  * Example:
    > ```bash=
    > $ liquibase --changeLogFile=changelog.<type>.sql generateChangeLog
    > ```
    > * 會將變更寫入到 `changelog.<type>.sql` 中。
* `update` / 更新資料庫
  * 更新資料庫，並且將變更寫入到資料庫中。
  * Example:
    > ```bash=
    > $ liquibase --changeLogFile=changelog.<type>.sql update
    > ```
    > * 會將 changelog file 中尚未被執行的變更寫入到資料庫中。
* `updateSQL` / 驗證 SQL
  * 檢查變更日誌，但不會寫入到資料庫中。
  * Example:
    > ```bash=
    > $ liquibase --changeLogFile=changelog.<type>.sql updateSQL
    > ```
    > * 會將 changelog file 中尚未被執行的變更，並且顯示出來。


## Refs
* 關於 JDBC 的連結，可以參考 [Using JDBC URL in Liquibase](https://docs.liquibase.com/workflows/liquibase-community/using-jdbc-url-in-liquibase.html)
* 關於 Database Connections 的說明，可以參考 [Database Connections](https://docs.liquibase.com/concepts/connections/database-connections.html)
* 關於 Liquibase 認為的格式結構和說明，可以參考 [Best Practices](https://docs.liquibase.com/concepts/bestpractices.html)
<!-- 
https://docs.liquibase.com/concepts/tracking-tables/tracking-tables.html
https://docs.liquibase.com/concepts/liquibase-security.html
https://docs.liquibase.com/concepts/connections/liquibase-environment-variables.html
https://docs.liquibase.com/change-types/home.html
https://docs.liquibase.com/commands/home.html
https://docs.liquibase.com/start/install/tutorials/home.html
-->
