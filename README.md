This SQL query builds a CREATE TABLE statement automatically, just providing the DatabaseName and TableName of the table for which you want to build the creation statement, it will automatically set the right datatype for each column.

It is optimized to run in a TERADATA RDBMS since uses some specific dictionary tables, but it is easily translatable in every RDBMS, just change the dictionary tables DBC.Databases, DBC.Tables, DBC.Columns.

Before running the sql query, you must change the following parameters:
$DatabaseName = replace it with the name of the database where currently stands the table which you want to build the creation statement
$TableName = replace it with the name of the table which you want to build the creation statement
$NewDatabaseName = replace it with the name of the database where the table will be recreate
$NewTableName = replace it with the new name of the table that will be recreate
