SELECT  X.CreateStmt (TITLE'')
FROM    (
        SELECT   T.DatabaseName
                ,T.TableName
                ,C.ColumnID
                ,CASE
                        WHEN    C.IdColType IS NOT NULL
                        THEN    'CAST(0 AS '||
                                 CASE    C.ColumnType
                                         WHEN   'I'
                                         THEN   'VARCHAR(11)'
                                         WHEN   'I1'
                                         THEN   'VARCHAR(4)'
                                         WHEN   'I2'
                                         THEN   'VARCHAR(6)'
                                         WHEN   'I8'
                                         THEN   'VARCHAR(20)'
                                         WHEN   'D'
                                         THEN   'VARCHAR('|| TRIM(C.DecimalTotalDigits + 2)|| ')'
                                         ELSE   'VARCHAR(18)'
                                 END
                                ||') ' || 'AS ' || TRIM(C.ColumnName)
                        ELSE    'CAST(' || TRIM(C.ColumnName) || ' AS VARCHAR(' ||
                                CASE    C.ColumnType
                                        WHEN    'I'             --Integer
                                        THEN    '11'
                                        WHEN    'I1'            --Byteint
                                        THEN    '4'
                                        WHEN    'I2'            --Smallint
                                        THEN    '6'
                                        WHEN    'I8'            --Bigint
                                        THEN    '20'
                                        WHEN    'D'             --Decimal
                                        THEN    TRIM(C.DecimalTotalDigits + 2)
                                        WHEN    'DA'            --Date
                                        THEN    '10'
                                        WHEN    'TS'            --Timestamp
                                        THEN    '26'
                                        WHEN    'F'             --Float
                                        THEN    '100'
                                        WHEN    'CF'            --Char
                                        THEN    TRIM(C.ColumnLength)
                                        WHEN    'CV'            --VarChar
                                        THEN    TRIM(C.ColumnLength)
                                        ELSE    '500'
                                END
                                || ')) AS ' || TRIM(C.ColumnName)
                 END AS COLEXPR
                ,CAST(  CASE
                            WHEN    C.ColumnID = MIN(C.ColumnID) OVER (PARTITION BY C.DatabaseName, C.TableName)
                            THEN    CASE
                                            WHEN    C.ColumnID = MAX(C.ColumnID) OVER (PARTITION BY C.DatabaseName, C.TableName)
                                            THEN    'CREATE MULTISET TABLE ' || '$NewDatabaseName'||'.'||'$NewTableName' || ' AS (SELECT ' || COLEXPR || ' FROM '|| TRIM(C.DatabaseName) || '.' || TRIM(C.TableName)||') WITH NO DATA NO PRIMARY INDEX;'
                                            ELSE    'CREATE MULTISET TABLE ' || '$NewDatabaseName'||'.'||'$NewTableName' || ' AS (SELECT ' || COLEXPR
                                    END
                            ELSE    CASE
                                            WHEN    C.ColumnID = MAX(C.ColumnID) OVER (PARTITION BY C.DatabaseName, C.TableName)
                                            THEN    ','||COLEXPR || ' FROM '|| TRIM(C.DatabaseName) || '.' || TRIM(C.TableName)||') WITH NO DATA NO PRIMARY INDEX;'
                                            ELSE    ','||COLEXPR
                                    END        
                        END
                        AS VARCHAR(500)
                )AS CreateStmt

        FROM    DBC.COLUMNS C
                INNER JOIN
                DBC.Tables T
                ON C.DatabaseName = T.DatabaseName
                AND C.TableName = T.TableName

        WHERE   T.TableKind IN ('T','O')
                AND T.DatabaseName = '$TableName'
                AND T.TableName = '$DatabaseName'
        ) X
        ORDER BY X.DatabaseName, X.TableName, X.ColumnID
	;