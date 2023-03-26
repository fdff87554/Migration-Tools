# Flyway
* 此紀錄為紀錄 Flyway 的使用方法，並且說明如何使用 Flyway 來管理資料庫的版本。
> * 本文件操作環境為 S: ubuntu 22.04 server / Database: 10.6.12-MariaDB-0ubuntu0.22.04.1 / Flyway: 9.16.1

## Overview / 概述
* Flyway 是一個資料庫版本管理工具，它可以讓你在資料庫上執行變更，並且利用頗乾淨的方式來管理這些變更。
* Flyway 是可以做到版本回滾的，但**需要付費**，community 版本無法做到版本回滾。
* Flyway 有幾個核心的文件，其分別為
  * `conf/flyway.conf`：設定檔，用來設定資料庫的連線資訊。
  * `sql/`：資料庫變更的 SQL 檔案，這些檔案會依照檔名的順序來執行。
* Flyway 還有其他設定文件跟非基本的功能，有些是付費的，有些是免費的，但是我們不會在這裡討論到。


## Installation / 安裝
* 安裝 Flyway 的流程蠻簡單的，只要下載它的執行檔，並且設定好設定檔就可以了。
* 在 Flyway 的 `.tar.gz` 檔案中，會有包含檔案範例，這些檔案可以直接複製到你的專案中，並且修改成你需要的樣子。
* 在 Repo 中有準備一份安裝 Flyway 的腳本，可以直接執行，請注意需要適當的調整 Flyway 的版本和其他的設定，請直接看 `install/debain_ubuntu.sh` 檔案。
  * 安裝腳本會於 `$HOME` 目錄創建一個 `flyway` 的目錄，並且將 Flyway 的範例檔案複製到這個目錄中。
  > * 相關安裝說明請參考 `debian_ubuntu.sh` 的註解。

## Usage / 使用
* 要使用 Flyway 來管理資料庫，需要先設定好 `conf/flyway.conf` 這個設定檔，並且將資料庫的連線資訊填入。
* 並且撰寫要執行的不同版本的 SQL 檔案，並且放到 `sql/` 目錄中。

### Directory Structure / 目錄結構
* Flyway 的目錄結構如下
  > ```markdown=
  > ├── conf
  > │   └── flyway.conf
  > ├── sql
  > │   ├── V1__create_table.sql
  > │   ├── V2__add_column.sql
  > │   └── ...
  > └── Other Files
  > ```

### Setup `conf/flyway.conf` / 設定 `conf/flyway.conf`
* 要管理資料庫的更變，理論上本來就需要告訴工具你的資料庫資訊，包含
  * 要操作的資料庫管理工具
  * 要操作的資料庫
  * 要使用的操作使用者名稱
  * 要使用的操作使用者密碼
  * 我們操作的資料庫行為的檔案
* 那 Flyway 也是一樣，我們需要告訴 Flyway 這些資訊，所以我們需要準備一個 `flyway.conf` 來記錄這些資訊。
* 在初始化的時候，我們可以直接複製 `conf/flyway.conf` 這個檔案，並且修改成我們需要的樣子。
* 在 `flyway.conf` 這份檔案中，
  * `flyway.url` - 資料庫的連線網址，包含資料庫管理工具、資料庫名稱、連線的使用者名稱、連線的使用者密碼。
    > * 可以依照使用的 DBMS 參考上面的 Example 撰寫，例如這邊使用的是 MariaDB，所以可以撰寫成 `jdbc:mariadb://localhost:3306/flyway`
  * `flyway.user` - 資料庫的使用者名稱。
  * `flyway.password` - 資料庫的使用者密碼。
  * `flyway.locations` - 資料庫的變更檔案的位置。
    > * `filesystem` - 代表使用本地端的檔案系統。以範例為例，就是 `filesystem:sql`。
    > * `s3` - 代表使用 aws s3 的檔案系統。以範例為例，就是 `s3:path-of-s3`。
    > * 其他可以參考 [Flyway Migrations](https://flywaydb.org/documentation/concepts/migrations)。

### Write `sql/` / 寫 `sql/`
* 在 `sql/` 目錄中，我們可以撰寫不同版本的 SQL 檔案，並且依照檔名的順序來執行。
* Flyway 管理資料庫的版本是依照檔名來管理的，所以我們需要依照一定的規則來命名檔案。

#### Naming Rule / 命名規則
* Versioned Migration Files / 版本化的 Migration 檔案
  * Flyway 的檔名規則如下
    > ```markdown=
    > V<版本號碼>__<描述>.<副檔名>
    > ```
    > * V 是 Prefix，代表這是一個版本化的 Migration 檔案。
    > * `<版本號碼>` 是版本號碼，可以是任何數字，但是必須是連續的，例如 `V1__create_table.sql`、`V2__add_column.sql`、`V3__add_index.sql`。
    > * `__` 是分隔符號，代表這是版本號碼和描述的分隔符號。
    > * `<描述>` 是描述，可以是任何文字，但是不可以有空白，例如 `V1__create_table.sql`、`V2__add_column.sql`、`V3__add_index.sql`。
    > * `<副檔名>` 是副檔名，必須是 `sql`，例如 `V1__create_table.sql`、`V2__add_column.sql`、`V3__add_index.sql`。
  * 例如，我們要新增一個 `create_table` 的檔案，我們可以命名成 `V1__create_table.sql`。
  * 這個檔案會在執行的時候，被 Flyway 讀取，並且執行裡面的 SQL 語法。
  * 這個檔案會被執行後，會在 `flyway_schema_history` 這個資料表中，新增一筆紀錄，紀錄這個檔案的版本號碼、執行時間、執行的 SQL 語法等等。
* Undo Migration Files / 撤銷化的 Migration 檔案 (注意此功能只有付費版有)
  * Flyway 的檔名規則如下
    > ```markdown=
    > U<版本號碼>__<描述>.<副檔名>
    > ```
    > * U 是 Prefix，代表這是一個撤銷化的 Migration 檔案。
    > * 其餘同上。
  * 例如，我們要撤銷剛剛的 `create_table` 的檔案，我們可以命名成 `U1__create_table.sql`。
* Repeatable Migrations / 可重複的 Migration 檔案
  * Flyway 的檔名規則如下
    > ```markdown=
    > R__<描述>.<副檔名>
    > ```
    > * R 是 Prefix，代表這是一個可重複的 Migration 檔案。
    > * 在 Repeatable 下，Version Number 會被忽略，所以不需要寫。
    > * 其餘同上。
    * 例如，我們要新增一個 `create_table` 的檔案，我們可以命名成 `R__create_table.sql`。

## Commands / 指令


