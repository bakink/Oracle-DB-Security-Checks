/* 

Run this script   sqlplus system/password@ServerName:Port/ServiceName  @Oracle12c-Checks.sql
Output  filename is : DBName_yymmdd_Security_Checks.html

 */

set pagesize 10000
SET TERMOUT OFF
SET RECSEP WRAPPED

colum  expiry_date  format a15
column GRANTED_CRITIC_ROLE format A20
column ADMIN_OPTION format A15
column COMMON format A15
column SYSDBA format A15
column SYSOPER format A15
column SYSASM format A15
column SYSBACKUP format A15
column SYSDG format A15
column SYSKM format A15
column DB_UNIQUE_NAME format A15
column AUDIT_TRAIL format A15
column POLICY_COLUMN_OPTIONS format A25
column ENABLED format A15
column OBJECT_SCHEMA format A15
column OBJECT_NAME format A32
column POLICY_OWNER format A15
column POLICY_NAME format A25
column POLICY_TEXT format A32
column POLICY_COLUMN format A15
column PF_SCHEMA format A15
column PF_PACKAGE format A15
column PF_FUNCTION format A15
column PRIVILEGE format A15
column IS_GRANT format A15
column INVERT format A15
column ENABLED_OPT format A15
column SUCCESS format A15
column FAILURE format A15
column INVERTED_PRINCIPAL format A25
column PRINCIPAL format A15
column PRINCIPAL_TYPE format A25


SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP ON -
HEAD '<TITLE>  </TITLE> -
<STYLE type="text/css"> -
th { -
font:bold 10pt Ariel,Helvetica,sans-serif; -
color:#336699; -
background:#cccc99; -
padding:3px 3px 3px 3px;} -
td { -
font: 9pt Arial,Helvetica,sans-serif; -
color:black; -
background:white; -
padding:2px 2px 2px 2px;} -
</STYLE>' -
BODY 'TEXT="#00000"' -
TABLE 'WIDTH="60%" BORDER="1"'


column filename new_val filename
select name||'_'||to_char(sysdate, 'yyyymmdd' )||'_Security_Checks.html' filename from dual , v$database;
spool &filename

set define off

SET MARKUP HTML   OFF
Prompt  <h2> Oracle 12c Security Check SQLs </h2>
Prompt  <p>Open Source code from  https://github.com/yusufanilakduygu/Oracle-DB-Security-Checks </p>
Prompt  <p>This Report was developed by Y. Anil Akduygu ver 1.1 2018 </p>

Prompt  <h3> Server and Database Information  </h3>
SET MARKUP HTML   ON

SELECT to_char(SYSDATE,'dd-mm-yyyy hh24:mi') REPORT_DATE,
       SUBSTR (host_name, 1, 20) HOST_NAME,
       name,
       database_role,
       SUBSTR (open_mode, 1, 10) OPEN_MODE,
       SUBSTR (db_unique_name, 1, 10) DB_UNIQUE_NAME,
	   CDB
  FROM v$database, v$instance;

SET MARKUP HTML   OFF
prompt </b>
prompt <h3>   Database version  </h3>
SET MARKUP HTML   ON

SELECT BANNER "DB VERSION INFORMATION" from v$version;

SET MARKUP HTML   OFF
prompt </b>
prompt <h3>   Check - 010 User List  </h3>
SET MARKUP HTML   ON
 
colum  expiry_date  format a15

SELECT
	USERNAME,
	ACCOUNT_STATUS,
	CREATED,
	ORACLE_MAINTAINED
FROM
	DBA_USERS
WHERE
	ORACLE_MAINTAINED <> 'Y'
ORDER BY
	ACCOUNT_STATUS DESC,
	USERNAME;

 
SET MARKUP HTML   OFF
prompt <h3>   Check - 020 List Permanent and Temporary Tablespaces  </h3>
SET MARKUP HTML   ON

SELECT
	PROPERTY_NAME,
	PROPERTY_VALUE
FROM
	DATABASE_PROPERTIES
WHERE
	PROPERTY_NAME IN(
		'DEFAULT_PERMANENT_TABLESPACE',
		'DEFAULT_TEMP_TABLESPACE'
	);

SET MARKUP HTML OFF
prompt <h3>   Check - 030 Users which use SYSTEM and SYSAUX as Default Tablespaces  </h3>
SET MARKUP HTML   ON

SELECT
	USERNAME,
	DEFAULT_TABLESPACE,
	TEMPORARY_TABLESPACE
FROM
	DBA_USERS
WHERE
	(
		DEFAULT_TABLESPACE IN(
			'SYSTEM',
			'SYSAUX'
		)
		OR TEMPORARY_TABLESPACE IN(
			'SYSTEM',
			'SYSAUX'
		)
	)
	AND ORACLE_MAINTAINED = 'N'

SET MARKUP HTML OFF
prompt <h3>   Check - 035 List Users Last Login Date  </h3>
SET MARKUP HTML   ON

SELECT
	USERNAME,
	ACCOUNT_STATUS,
	TO_CHAR(LAST_LOGIN,'DD-MM-YYYY HH24:MI') LAST_LOGIN
FROM
	DBA_USERS
WHERE
	ACCOUNT_STATUS = 'OPEN';

	
SET MARKUP HTML OFF
prompt <h3>   Check - 040 List Sample Application Users  </h3>
SET MARKUP HTML   ON

SELECT
	DISTINCT(USERNAME)
FROM
	DBA_USERS
WHERE
	USERNAME IN(
		'BI',
		'HR',
		'OE',
		'PM',
		'IX',
		'SH',
		'SCOTT'
	);

SET MARKUP HTML OFF
prompt <h3>   Check - 050 List  Database Profile Names  </h3>
SET MARKUP HTML   ON
	
SELECT
	DISTINCT PROFILE
FROM
	DBA_PROFILES
ORDER BY
	PROFILE;
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 060 List  Database Profiles Details  </h3>
SET MARKUP HTML   ON

SELECT
	*
FROM
	DBA_PROFILES
ORDER BY
	PROFILE;

SET MARKUP HTML OFF
prompt <h3>   Check - 070 List Unused Database Profiles  </h3>
SET MARKUP HTML   ON	
	
SELECT
	DISTINCT PROFILE
FROM
	DBA_PROFILES MINUS SELECT
		DISTINCT PROFILE
	FROM
		DBA_USERS;
	
SET MARKUP HTML OFF
prompt <h3>   Check - 080 List User and Profile Usage  </h3>
SET MARKUP HTML   ON	
	
SELECT
	USERNAME,
	PROFILE
FROM
	DBA_USERS
ORDER BY
	PROFILE;

SET MARKUP HTML OFF
prompt <h3>   Check - 080 List resource_limit parameter  </h3>
SET MARKUP HTML   ON

SELECT
	NAME,
	VALUE
FROM
	V$PARAMETER
WHERE
	NAME = 'resource_limit';

SET MARKUP HTML OFF
prompt <h3>   Check - 090 List Resource Usage Profile Parameters  </h3>
SET MARKUP HTML   ON

SELECT
	PROFILE,
	RESOURCE_NAME,
	LIMIT
FROM
	DBA_PROFILES
WHERE
	RESOURCE_NAME IN(
		'SESSIONS_PER_USER',
		'CPU_PER_SESSION',
		'CPU_PER_CALL',
		'CONNECT_TIME',
		'IDLE_TIME',
		'LOGICAL_READS_PER_SESSION',
		'PRIVATE_SGA',
		'COMPOSITE_LIMIT'
	)
ORDER BY
	PROFILE,
	RESOURCE_NAME;

SET MARKUP HTML OFF
prompt <h3>   Check - 100 List resource_manager_plan parameters  </h3>
SET MARKUP HTML   ON

SELECT
	NAME,
	VALUE
FROM
	V$PARAMETER
WHERE
	NAME LIKE 'resource_manager_plan';

SET MARKUP HTML OFF
prompt <h3>   Check - 110 List Resource Plans  </h3>
SET MARKUP HTML   ON

SELECT
	NAME,
	IS_TOP_PLAN
FROM
	V$RSRC_PLAN;


SET MARKUP HTML OFF
prompt <h3>   Check - 120 List Password Parameters  </h3>
SET MARKUP HTML   ON

SELECT
	PROFILE,
	RESOURCE_NAME,
	LIMIT
FROM
	DBA_PROFILES
WHERE
	RESOURCE_NAME IN(
		'FAILED_LOGIN_ATTEMPTS',
		'PASSWORD_LIFE_TIME',
		'PASSWORD_LOCK_TIME',
		'PASSWORD_GRACE_TIME',
		'PASSWORD_VERIFY_FUNCTION',
		'PASSWORD_REUSE_TIME',
		'PASSWORD_REUSE_MAX'
	)
ORDER BY
	PROFILE,
	RESOURCE_NAME;
	

SET MARKUP HTML OFF
prompt <h3>   Check - 130 List Profiles with NULL Password Verify Function  </h3>
SET MARKUP HTML   ON

SELECT
	*
FROM
	DBA_PROFILES
WHERE
	RESOURCE_NAME = 'PASSWORD_VERIFY_FUNCTION'
	AND(
		LIMIT = 'DEFAULT'
		OR LIMIT IS NULL
		OR LIMIT = 'NULL'
	);


SET MARKUP HTML OFF
prompt <h3>   Check - 140 List  Default User with Default Passwords </h3>
SET MARKUP HTML ON

SELECT * FROM DBA_USERS_WITH_DEFPWD;


SET MARKUP HTML OFF
prompt <h3>   Check - 150 List Default Users with default passwords and not in EXPIRED and LOCKED status </h3>
SET MARKUP HTML ON


SELECT
	A.USERNAME ,
	B.ACCOUNT_STATUS 
FROM
	SYS.DBA_USERS_WITH_DEFPWD A,
	DBA_USERS B
WHERE
	A.USERNAME = B.USERNAME
	AND B.ACCOUNT_STATUS <> 'EXPIRED & LOCKED';

SET MARKUP HTML OFF
prompt <h3>   Check - 160 List Users with DBA role </h3>
SET MARKUP HTML ON

SELECT
	DISTINCT A.GRANTEE,
	A.GRANTED_ROLE,
	'DBA' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS START WITH GRANTED_ROLE = 'DBA' 
                                 CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';


SET MARKUP HTML OFF
prompt <h3>   Check - 180 List Users with IMP_FULL_DATABASE role </h3>
SET MARKUP HTML ON


SELECT
	DISTINCT A.GRANTEE,
	A.GRANTED_ROLE,
	'IMP_FULL_DATABASE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'IMP_FULL_DATABASE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';


SET MARKUP HTML OFF
prompt <h3>   Check - 190 List Users with DATAPUMP_IMP_FULL_DATABASE role </h3>
SET MARKUP HTML ON

	
SELECT
	DISTINCT A.GRANTEE,
	A.GRANTED_ROLE,
	'DATAPUMP_IMP_FULL_DATABASE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'DATAPUMP_IMP_FULL_DATABASE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';


SET MARKUP HTML OFF
prompt <h3>   Check - 200 List Users with EXP_FULL_DATABASE role </h3>
SET MARKUP HTML ON


SELECT
	DISTINCT A.GRANTEE,
	A.GRANTED_ROLE,
	'EXP_FULL_DATABASE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'EXP_FULL_DATABASE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';


SET MARKUP HTML OFF
prompt <h3>   Check - 210 List Users with DATAPUMP_EXP_FULL_DATABASE role </h3>
SET MARKUP HTML ON
	

SELECT
	DISTINCT A.GRANTEE,
	A.GRANTED_ROLE,
	'DATAPUMP_EXP_FULL_DATABASE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'DATAPUMP_EXP_FULL_DATABASE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';


SET MARKUP HTML OFF
prompt <h3>   Check - 220 List Users with SELECT_CATALOG_ROLE role </h3>
SET MARKUP HTML ON

SELECT
	DISTINCT A.GRANTEE,
	GRANTED_ROLE,
	'SELECT_CATALOG_ROLE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'SELECT_CATALOG_ROLE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS',
		'SYSMAN'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';

SET MARKUP HTML OFF
prompt <h3>   Check - 230 List Users with DELETE_CATALOG_ROLE role </h3>
SET MARKUP HTML ON

SELECT
	DISTINCT A.GRANTEE,
	GRANTED_ROLE,
	'DELETE_CATALOG_ROLE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
START WITH GRANTED_ROLE = 'DELETE_CATALOG_ROLE' 
CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS',
		'SYSMAN'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';

SET MARKUP HTML OFF
prompt <h3>   Check - 240 List Users with EXECUTE_CATALOG_ROLE role </h3>
SET MARKUP HTML ON

SELECT
	DISTINCT A.GRANTEE,
	GRANTED_ROLE,
	'EXECUTE_CATALOG_ROLE' GRANTED_CRITIC_ROLE
FROM
	(
		SELECT
			DISTINCT LEVEL LEVEL_DEEP,
			GRANTEE,
			GRANTED_ROLE
		FROM
			DBA_ROLE_PRIVS 
			START WITH GRANTED_ROLE = 'EXECUTE_CATALOG_ROLE' 
			CONNECT BY PRIOR GRANTEE = GRANTED_ROLE
	) A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.USERNAME NOT IN(
		'SYSTEM',
		'SYS',
		'SYSMAN'
	)
	AND B.ACCOUNT_STATUS = 'OPEN';

SET MARKUP HTML OFF
prompt <h3>   Check - 250 List remote_login_passwordfile parameter </h3>
SET MARKUP HTML ON
SELECT
	NAME,
	VALUE
FROM
	V$PARAMETER
WHERE
	NAME = 'remote_login_passwordfile';


SET MARKUP HTML OFF
prompt <h3>   Check - 260 List Users which use password file </h3>
SET MARKUP HTML ON

SELECT * FROM V$PWFILE_USERS;


SET MARKUP HTML OFF
prompt <h3>   Check - 270 List users and roles with critic privileges  </h3>
SET MARKUP HTML ON

SELECT
	A.*,
	'GRANTED TO USER' TYPE
FROM
	DBA_SYS_PRIVS A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y'
	AND PRIVILEGE IN(
		'BECOME USER',
		'ALTER USER',
		'DROP USER',
		'CREATE ROLE',
		'ALTER ANY ROLE',
		'DROP ANY ROLE',
		'GRANT ANY ROLE',
		'CREATE PROFILE',
		'ALTER PROFILE',
		'DROP PROFILE',
		'CREATE ANY TABLE',
		'ALTER ANY TABLE',
		'DROP ANY TABLE',
		'INSERT ANY TABLE',
		'UPDATE ANY TABLE',
		'DELETE ANY TABLE',
		'SELECT ANY TABLE',
		'CREATE ANY PROCEDURE',
		'ALTER ANY PROCEDURE',
		'DROP ANY PROCEDURE',
		'EXECUTE ANY PROCEDURE',
		'CREATE ANY TRIGGER',
		'ALTER ANY TRIGGER',
		'DROP ANY TRIGGER',
		'CREATE TABLESPACE',
		'ALTER TABLESPACE',
		'DROP TABLESPACES',
		'ALTER DATABASE',
		'ALTER SYSTEM',
		'SELECT ANY DICTIONARY',
		'EXEMPT ACCESS POLICY',
		'CREATE ANY LIBRARY',
		'GRANT ANY OBJECT PRIVILEGE',
		'GRANT ANY PRIVILEGE',
		'AUDIT ANY'
	)
UNION ALL 
SELECT
	A.*,
	'GRANTED TO ROLE' TYPE
FROM
	DBA_SYS_PRIVS A,
	DBA_ROLES B
WHERE
	A.GRANTEE = B.ROLE
	AND PRIVILEGE IN(
		'BECOME USER',
		'ALTER USER',
		'DROP USER',
		'CREATE ROLE',
		'ALTER ANY ROLE',
		'DROP ANY ROLE',
		'GRANT ANY ROLE',
		'CREATE PROFILE',
		'ALTER PROFILE',
		'DROP PROFILE',
		'CREATE ANY TABLE',
		'ALTER ANY TABLE',
		'DROP ANY TABLE',
		'INSERT ANY TABLE',
		'UPDATE ANY TABLE',
		'DELETE ANY TABLE',
		'SELECT ANY TABLE',
		'CREATE ANY PROCEDURE',
		'ALTER ANY PROCEDURE',
		'DROP ANY PROCEDURE',
		'EXECUTE ANY PROCEDURE',
		'CREATE ANY TRIGGER',
		'ALTER ANY TRIGGER',
		'DROP ANY TRIGGER',
		'CREATE TABLESPACE',
		'ALTER TABLESPACE',
		'DROP TABLESPACES',
		'ALTER DATABASE',
		'ALTER SYSTEM',
		'SELECT ANY DICTIONARY',
		'EXEMPT ACCESS POLICY',
		'CREATE ANY LIBRARY',
		'GRANT ANY OBJECT PRIVILEGE',
		'GRANT ANY PRIVILEGE',
		'AUDIT ANY'
	)
	AND B.ORACLE_MAINTAINED <> 'Y';

	
SET MARKUP HTML OFF
prompt <h3>   Check - 280 List DEFAULT Packages which are granted to PUBLIC with EXECUTE privileges   </h3>
SET MARKUP HTML ON
	
SELECT
	OWNER,
	TABLE_NAME,
	PRIVILEGE,
	GRANTEE
FROM
	DBA_TAB_PRIVS
WHERE
	GRANTEE = 'PUBLIC'
	AND PRIVILEGE = 'EXECUTE'
	AND TABLE_NAME IN(
		'DBMS_ADVISOR',
		'DBMS_CRYPTO',
		'DBMS_JAVA',
		'DBMS_JAVA_TEST',
		'DBMS_JOB',
		'DBMS_LDAP',
		'DBMS_LOB',
		'DBMS_OBFUSCATION_TOOLKIT',
		'DBMS_RANDOM',
		'DBMS_SCHEDULER',
		'DBMS_SQL',
		'DBMS_XMLGEN',
		'DBMS_XMLQUERY',
		'UTL_FILE',
		'UTL_INADDR',
		'UTL_TCP',
		'UTL_MAIL',
		'UTL_SMTP',
		'UTL_DBWS',
		'UTL_ORAMTS',
		'UTL_HTTP',
		'HTTPURITYPE',
		'DBMS_SYS_SQL',
		'DBMS_BACKUP_RESTORE',
		'DBMS_AQADM_SYSCALLS',
		'DBMS_REPCAT_SQL_UTL',
		'INITJVMAUX',
		'DBMS_STREAMS_ADM_UTL',
		'DBMS_AQADM_SYS',
		'DBMS_STREAMS_RPC',
		'DBMS_PRVTAQIM',
		'LTADM',
		'WWV_DBMS_SQL',
		'WWV_EXECUTE_IMMEDIATE',
		'DBMS_IJOB',
		'DBMS_FILE_TRANSFER'
	)
ORDER BY
TABLE_NAME;

SET MARKUP HTML OFF
prompt <h3>   Check - 290 List Grants on critic tables   </h3>
SET MARKUP HTML ON

SELECT
	GRANTEE,
	PRIVILEGE,
	TABLE_NAME
FROM
	DBA_TAB_PRIVS
WHERE
	TABLE_NAME IN(
		'AUD$',
		'USER_HISTORY$',
		'LINK$',
		'USER$',
		'SCHEDULER$_CREDENTIAL'
	)
	AND GRANTEE NOT IN(
		'ANONYMOUS',
		'APEX_040200',
		'APEX_PUBLIC_USER',
		'APPQOSSYS',
		'AUDSYS',
		'CTXSYS',
		'DBSNMP',
		'DIP',
		'DVF',
		'DVSYS',
		'EXFSYS',
		'FLOWS_FILES',
		'GSMADMIN_INTERNAL',
		'GSMCATUSER',
		'GSMUSER',
		'LBACSYS',
		'MDDATA',
		'MDSYS',
		'ORACLE_OCM',
		'ORDDATA',
		'ORDPLUGINS',
		'ORDSYS',
		'OUTLN',
		'SI_INFORMTN_SCHEMA',
		'SPATIAL_CSW_ADMIN_USR',
		'SPATIAL_WFS_ADMIN_USR',
		'SYS',
		'SYSBACKUP',
		'SYSDG',
		'SYSKM',
		'SYSTEM',
		'WMSYS',
		'XDB',
		'XS$NULL',
		'OLAPSYS',
		'OJVMSYS',
		'DV_SECANALYST'
	);


SET MARKUP HTML OFF
prompt <h3>   Check - 300 List Objects Priviliges Granted to Public    </h3>
SET MARKUP HTML ON
	
SELECT
	A.GRANTEE,
	A.OWNER,
	A.TABLE_NAME,
	A.PRIVILEGE
FROM
	DBA_TAB_PRIVS A,
	DBA_USERS B
WHERE
	GRANTEE = 'PUBLIC'
	AND A.OWNER = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y';

	
SET MARKUP HTML OFF
prompt <h3>   Check - 302 List  Roles Granted to Public   </h3>
SET MARKUP HTML ON

SELECT
	GRANTEE,
	GRANTED_ROLE
FROM
	DBA_ROLE_PRIVS
WHERE
	GRANTEE = 'PUBLIC';


SET MARKUP HTML OFF
prompt <h3>   Check - 304 List  System Privileges  Granted to Public   </h3>
SET MARKUP HTML ON	

SELECT
	GRANTEE,
	PRIVILEGE
FROM
	DBA_SYS_PRIVS
WHERE
	GRANTEE = 'PUBLIC';
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 310 List Granted System Priviliges to Users with Admin Option   </h3>
SET MARKUP HTML ON

SELECT
	A.GRANTEE,
	A.PRIVILEGE,
	A.ADMIN_OPTION
FROM
	DBA_SYS_PRIVS A,
	DBA_USERS B
WHERE
	A.GRANTEE = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y'
	AND A.ADMIN_OPTION = 'YES';



SET MARKUP HTML OFF
prompt <h3>   Check - 320 List Granted  System Priviliges to Roles with Admin Option   </h3>
SET MARKUP HTML ON	

SELECT
	A.GRANTEE,
	A.PRIVILEGE,
	A.ADMIN_OPTION
FROM
	DBA_SYS_PRIVS A,
	DBA_ROLES B
WHERE
	A.ADMIN_OPTION = 'YES'
	AND A.GRANTEE = B.ROLE
	AND B.ORACLE_MAINTAINED <> 'Y';
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 322 List Roles Granted to Users   with Admin Option   </h3>
SET MARKUP HTML ON	

SELECT
	A.GRANTEE,
	A.GRANTED_ROLE,
    A.ADMIN_OPTION
FROM
	DBA_ROLE_PRIVS A,
	DBA_USERS B
WHERE
	A.ADMIN_OPTION = 'YES'
	AND A.GRANTEE = B.USERNAME
	AND B.ORACLE_MAINTAINED  <> 'Y';


SET MARKUP HTML OFF
prompt <h3>   Check - 324 List Roles Granted to Roles   with Admin Option   </h3>
SET MARKUP HTML ON

SELECT
	A.GRANTEE,
	A.GRANTED_ROLE,
A.ADMIN_OPTION
FROM
	DBA_ROLE_PRIVS A,
	DBA_ROLES B
WHERE
	A.ADMIN_OPTION = 'YES'
	AND A.GRANTEE = B.ROLE
	AND B.ORACLE_MAINTAINED  <> 'Y';


SET MARKUP HTML OFF
prompt <h3>   Check - 328 List Object Privileges with Grant Option   </h3>
SET MARKUP HTML ON	
		
SELECT
	A.GRANTEE,
	A.OWNER,
	A.TABLE_NAME,
	A.GRANTABLE,
	A.PRIVILEGE
FROM
	DBA_TAB_PRIVS A,
	DBA_USERS B,
	DBA_USERS C
WHERE
	GRANTABLE = 'YES'
	AND A.OWNER = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y'
	AND A.GRANTEE = C.USERNAME
	AND C.ORACLE_MAINTAINED <> 'Y';

	
SET MARKUP HTML OFF
prompt <h3>   Check - 330 List Users with UNLIMITED TABLESPACE Privilege   </h3>
SET MARKUP HTML ON

SELECT
	A.GRANTEE,
	A.PRIVILEGE,
	A.ADMIN_OPTION
FROM
	DBA_SYS_PRIVS A,
	DBA_USERS B
WHERE
	A.PRIVILEGE = 'UNLIMITED TABLESPACE'
	AND A.GRANTEE = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y';


	
SET MARKUP HTML OFF
prompt <h3>   Check - 340 List Users with Unlimited Tablespaces Quotas   </h3>
SET MARKUP HTML ON	

SELECT
	A.TABLESPACE_NAME,
	A.USERNAME
FROM
	DBA_TS_QUOTAS A,
	DBA_USERS B
WHERE
	A.MAX_BYTES = - 1
	AND A.USERNAME = B.USERNAME
	AND B.ORACLE_MAINTAINED <> 'Y';

SET MARKUP HTML OFF
prompt <h3>   Check - 350 List Database Components  </h3>
SET MARKUP HTML ON
	
SELECT
	COMP_ID,
	COMP_NAME,
	VERSION,
	STATUS,
	MODIFIED
FROM
	DBA_REGISTRY
ORDER BY
	COMP_ID;
	
SET MARKUP HTML OFF
prompt <h3>   Check - 360 List O7_DICTIONARY_ACCESSIBILITY parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'O7_DICTIONARY_ACCESSIBILITY';

SET MARKUP HTML OFF
prompt <h3>   Check - 370 List OS_ROLES parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'OS_ROLES';

SET MARKUP HTML OFF
prompt <h3>   Check - 380 List REMOTE_LISTENER parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'REMOTE_LISTENER';

SET MARKUP HTML OFF
prompt <h3>   Check - 390 List REMOTE_OS_AUTHENT parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'REMOTE_OS_AUTHENT';

SET MARKUP HTML OFF
prompt <h3>   Check - 400 List REMOTE_OS_ROLES parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'REMOTE_OS_ROLES';
	
SET MARKUP HTML OFF
prompt <h3>   Check - 410 List UTL_FILE_DIR parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'UTL_FILE_DIR';


SET MARKUP HTML OFF
prompt <h3>   Check - 420 List SEC_CASE_SENSITIVE_LOGON parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SEC_CASE_SENSITIVE_LOGON';
	
SET MARKUP HTML OFF
prompt <h3>   Check - 430 List SEC_MAX_FAILED_LOGIN_ATTEMPTS parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SEC_MAX_FAILED_LOGIN_ATTEMPTS';
	
SET MARKUP HTML OFF
prompt <h3>   Check - 440 List SEC_PROTOCOL_ERROR_FURTHER_ACTION parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SEC_PROTOCOL_ERROR_FURTHER_ACTION';


SET MARKUP HTML OFF
prompt <h3>   Check - 450 List SEC_PROTOCOL_ERROR_TRACE_ACTION parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SEC_PROTOCOL_ERROR_TRACE_ACTION';

SET MARKUP HTML OFF
prompt <h3>   Check - 460 List SEC_RETURN_SERVER_RELEASE_BANNER parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SEC_RETURN_SERVER_RELEASE_BANNER';
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 470 List SQL92_SECURITY parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'SQL92_SECURITY';

SET MARKUP HTML OFF
prompt <h3>   Check - 480 List RESOURCE_LIMIT parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'RESOURCE_LIMIT';
	
SET MARKUP HTML OFF
prompt <h3>   Check - 490 List AUDIT_SYS_OPERATIONS parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'AUDIT_SYS_OPERATIONS';
	
SET MARKUP HTML OFF
prompt <h3>   Check - 500 List AUDIT_TRAIL parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'AUDIT_TRAIL';

SET MARKUP HTML OFF
prompt <h3>   Check - 510 List GLOBAL_NAMES parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'GLOBAL_NAMES';

SET MARKUP HTML OFF
prompt <h3>   Check - 520 List LOCAL_LISTENER parameter  </h3>
SET MARKUP HTML ON
	
SELECT
	NAME,
	VALUE
FROM
	V$SYSTEM_PARAMETER
WHERE
	UPPER( NAME ) = 'LOCAL_LISTENER';


SET MARKUP HTML OFF
prompt <h3>   Check - 530 List Database Version  </h3>
SET MARKUP HTML ON
	
SELECT banner FROM v$version;

SET MARKUP HTML OFF
prompt <h3>   Check - 540 List Database Patch History  </h3>
SET MARKUP HTML ON

SELECT *
    FROM DBA_REGISTRY_HISTORY
ORDER BY action_time DESC;


SET MARKUP HTML OFF
prompt <h3>   Check - 550 List Database Data File Permissions For Unix\Linux Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test , Run these commands on Unix\Linux System Command Shell </p>
SET MARKUP HTML ON

SELECT
	'ls -lrt '||FILE_NAME "Unix\Linux commands"
FROM
	DBA_DATA_FILES;

SET MARKUP HTML OFF

prompt <h3>   Check - 555 List Database Data File Permissions For Windows Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test ,Run these commands on Windows PowerShell </p>
SET MARKUP HTML ON

SELECT
	'Icacls '||FILE_NAME "Windows commands"
FROM
	DBA_DATA_FILES;

	
SET MARKUP HTML OFF
prompt <h3>   Check - 560 List Control File Permissions For Unix\Linux Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test , Run these commands on Unix\Linux System Command Shell </p>
SET MARKUP HTML ON

SELECT
	'ls -lrt '||NAME "Unix\Linux commands"
FROM
	V$CONTROLFILE;

SET MARKUP HTML OFF
prompt <h3>   Check - 565 List Control File Permissions For Windows Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test , Run these commands on Windows PowerShell </p>
SET MARKUP HTML ON

SELECT
	'Icacls '||NAME "Windows commands"
FROM
	V$CONTROLFILE;	


SET MARKUP HTML OFF
prompt <h3>   Check - 570 List Redo Log File Permissions For Unix\Linux Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test , Run these commands on Windows PowerShell </p>
SET MARKUP HTML ON

SELECT
	'ls -lrt '||MEMBER "Unix\Linux commands"
FROM
	V$LOGFILE;
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 575 List Redo Log File Permissions For Windows Servers </h3>
prompt <p>  If the datafiles are on ASM skip this test , Run these commands on Windows PowerShell </p>
SET MARKUP HTML ON

SELECT
	'Icacls '||MEMBER "Windows commands"
FROM
	V$LOGFILE;

SET MARKUP HTML OFF
prompt <h3>   Check - 580 List Database Audit Parameters </h3>
SET MARKUP HTML ON

SELECT
	NAME,
	VALUE
FROM
	V$PARAMETER
WHERE
	UPPER( NAME ) IN(
		'AUDIT_TRAIL',
		'AUDIT_SYS_OPERATIONS'
	);

SET MARKUP HTML OFF
prompt <h3>   Check - 590  List Audited Privileges </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	DBA_PRIV_AUDIT_OPTS	
ORDER BY
	USER_NAME,
	PRIVILEGE;

SET MARKUP HTML OFF
prompt <h3>   Check - 600  List Audited Statements </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	DBA_STMT_AUDIT_OPTS
ORDER BY
	USER_NAME,
	AUDIT_OPTION;

SET MARKUP HTML OFF
prompt <h3>   Check - 610  List Audited Objects </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	DBA_OBJ_AUDIT_OPTS
ORDER BY
	OWNER,
	OBJECT_NAME;
	

SET MARKUP HTML OFF
prompt <h3>   Check - 620  List Audit Default Options </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	ALL_DEF_AUDIT_OPTS;
	
SET MARKUP HTML OFF
prompt <h3>   Check - 630  List Fine Grained Auditing Options </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	ALL_AUDIT_POLICIES;
	
	
SET MARKUP HTML OFF
prompt <h3>   Check - 632  List Unified Policies </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	AUDIT_UNIFIED_POLICIES;

SET MARKUP HTML OFF
prompt <h3>   Check - 634  List Unified Enabled Policies  </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	AUDIT_UNIFIED_ENABLED_POLICIES;

	
SET MARKUP HTML OFF
prompt <h3>   Check - 640  List Database Backups with RMAN  </h3>
SET MARKUP HTML ON	

SELECT
	SESSION_KEY,
	INPUT_TYPE,
	STATUS,
	TO_CHAR( START_TIME, 'DD/MM/YY HH24:MI' ) START_TIME,
	TO_CHAR( END_TIME, 'DD/MM/YY HH24:MI' ) END_TIME,
	TRUNC(( ELAPSED_SECONDS / 3600 ) * 60 ) MINUTES,
	TIME_TAKEN_DISPLAY
FROM
	V$RMAN_BACKUP_JOB_DETAILS
ORDER BY
	SESSION_KEY DESC;

SET MARKUP HTML OFF
prompt <h3>   Check - 650  List Database Protection Mode  </h3>
SET MARKUP HTML ON	

	
SELECT
	PROTECTION_MODE
FROM
	V$DATABASE;

SET MARKUP HTML OFF
prompt <h3>   Check - 660  List Archived Logs at Primary Side   </h3>
Prompt <p>  This script should   run on Primary Side </p>
SET MARKUP HTML ON	
	
SELECT
	SEQUENCE#,
	TO_CHAR( FIRST_TIME, 'DD-MM-YYYY HH24:MI' ) FIRST_TIME,
	TO_CHAR( NEXT_TIME,  'DD-MM-YYYY HH24:MI' ) NEXT_TIME
FROM
	V$ARCHIVED_LOG 
	WHERE 
	NEXT_TIME > SYSDATE - 2
ORDER BY
	SEQUENCE# desc;

SET MARKUP HTML OFF
prompt <h3>   Check - 665 List Archived Logs at Standby  Side   </h3>
Prompt <p> Run this script on Standby Side and compare it with Primary Side
prompt <br>	
prompt <br>	
prompt SELECT
Prompt <br>
Prompt NAME
Prompt <br>
Prompt SEQUENCE#,
Prompt <br>
Prompt TO_CHAR( FIRST_TIME, 'DD-MM-YYYY HH24:MI' ) FIRST_TIME,
Prompt <br>
Prompt TO_CHAR( NEXT_TIME,  'DD-MM-YYYY HH24:MI' ) NEXT_TIME
Prompt <br>
Prompt FROM
Prompt <br>
Prompt V$ARCHIVED_LOG
Prompt <br>
Prompt 	WHERE 
Prompt <br>
Prompt 	NEXT_TIME > SYSDATE - 2
Prompt <br>
Prompt ORDER BY
Prompt <br>
Prompt SEQUENCE# desc;
Prompt </p>
SET MARKUP HTML ON


SET MARKUP HTML OFF
prompt <h3>   Check - 670  List Database Links   </h3>
SET MARKUP HTML ON	

SELECT
	*
FROM
	DBA_DB_LINKS
ORDER BY
	HOST;

	
SET MARKUP HTML OFF
prompt <h3>   Check - 680  List PUBLIC Database Links   </h3>
SET MARKUP HTML ON

SELECT
	*
FROM
	DBA_DB_LINKS
WHERE 
	OWNER = 'PUBLIC'
ORDER BY
	HOST;

	
SET MARKUP HTML OFF
prompt <h3>   Check - 695  List ACL Definitions   </h3>
SET MARKUP HTML ON	
	
SELECT
	*
FROM
	DBA_HOST_ACLS;


SET MARKUP HTML OFF
prompt <h3>   Check - 705  List ACE Definitions   </h3>
SET MARKUP HTML ON	

SELECT
	*
FROM
	DBA_HOST_ACES;

Prompt	
Prompt *****  END OF SECURITY CHECKS REPORT  ****** 
	
spool off
exit
