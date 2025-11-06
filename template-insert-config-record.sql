/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [etl_config_id]
      ,[package_name]
      ,[table_type]
      ,[db_name]
      ,[schm_name]
      ,[table_name]
      ,[sproc_name]
      ,[is_active]
      ,[source_record_date]
      ,[source_record_id]
      ,[modified_user]
  FROM [edw].[admin].[etl_config]

insert into edw.admin.etl_config(package_name,table_type,db_name,schm_name,table_name,sproc_name,is_active,modified_user)
values('pkg_load_dim_table_name','type1_dim','edw','dbo','dim_table_name','dbo.usp_load_dim_chart_of_accounts',1,CURRENT_USER)