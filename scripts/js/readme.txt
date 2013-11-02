
::Mark:: Perforce location 
--------------------------
* //ariba/buyer/migrate/11s2/etc/sql/dbpatches/
* //ariba/devweb/ASM_Suite/versions/Platform/R1/Planning/QA/javascript/
* http://development/PSS/devtools/dfinlay/js/javascript.txt

::Mark:: Dave's collection 
--------------------------
* Clear cache, remove specific object from cache
* Access realm local
* Get alive node list
* Compare tomcat threads & jdbc connections
* Get JDBC connection info -- allocated, in-use, free
* Dump schema
* Get unused fields for classes
* Get all users, roles, groups, permissions
* Find the jar file from which a class is loaded

::Mark:: Schedule Tasks, PQ
---------------------------
(1) Dump list of queue managers:
var p = ariba.backplane.container.Backplane.getInstance().getQueueManager().getAllQueueManagers();
p;
(2) Disable task
//ariba/asm/migrate/release/generic/2.157.1.1+/etc/sql/dbpatches/DF_To_Disable_Data_Pull_Scheduled_Task
(3) Reschedule task
ariba.util.scheduler.ScheduleManager.getInstance("CoreServer").reschedule("None","PurgeSharedTempDirTask")
//ariba/asm/migrate/generic/etc/sql/dbpatches/12s1SpDF_1-CJGA4Z_10_09_2013/1-CJGA4Z_steps.txt

::Mark:: Schemas
----------------
(1) Get all transactional schemas:
var transactionSchemas = ariba.base.jdbcserver.DatabaseParameters.getDatabaseParameters().getTransactionalSchemas().toArray();

::Mark:: Session, BaseId
------------------------
var Base = ariba.base.core.Base;
var objPartition = Base.getService().getPartition("prealm_250");
var session = ariba.base.core.Base.getSession();
Base.getSession().setPartition(objPartition);
var objectId = ariba.base.core.BaseId.parse(oid);
var object = objectId .get();

::Mark:: Running SQL
--------------------
var AQLQuery = ariba.base.core.aql.AQLQuery;
var selectQuery = "select distinct FLEXSUPERTYPE from typemaptab where FLEXSUPERTYPE is not null and javatype like '%" + realmName + "%'";
var parsed_qry = AQLQuery.parseQuery(selectQuery);
var session = getSession (partitionName);
var options = new ariba.base.core.aql.AQLOptions(session.getPartition());
var defaultSchemaName = ariba.server.jdbcserver.JDBCUtil.getDefaultDatabaseSchemaName();
options.setDatabaseSchemaName(defaultSchemaName);
var resultset = Base.getService().executeQuery(parsed_qry, options);

::Mark:: Stuck requisitions
---------------------------
//ariba/buyer/migrate/12s2/etc/sql/dbpatches/12s2_1-CJP1Y9/12s2_1-CJP1Y9_JavaScript.txt
https://rc.ariba.com/cgi-bin/change-info?user=&change=2505265
https://rc.ariba.com/cgi-bin/change-info?user=&change=2492586
