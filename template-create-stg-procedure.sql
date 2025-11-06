create procedure {REPLACE_VALUE_SCHEMA_NAME}.usp_merge_{REPLACE_VALUE_TABLE_NAME}
as
merge into {REPLACE_VALUE_SCHEMA_NAME}.{REPLACE_VALUE_TABLE_NAME} tgt
using {REPLACE_VALUE_SCHEMA_NAME}.{REPLACE_VALUE_TABLE_NAME}_intermediate src
	on src.{REPLACE_VALUE_PRIMARY_KEY} = tgt.{REPLACE_VALUE_PRIMARY_KEY}
when matched then update set
	tgt.column1 = src.column1
	,tgt.column2 = src.column2
	
when not matched then insert (
	column1
	,column2
	) values (
	src.column1
	,src.column2
	);