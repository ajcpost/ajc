
::Mark:: Durable email
----------------------
(1) Typical NQM query
SELECT Dur1.rootId, Dur1.dem_RetryCount, Dur1.dem_TimeCreated FROM DurableEmailTab Dur1 WHERE (Dur1.dem_ProcessingNode = ' ' OR Dur1.dem_ProcessingNode IS NULL) AND ((Dur1.dem_RetryCount < 96 AND Dur1.dem_TimeUpdated < to_Date('2013-07-17 03:52:46','yyyy-mm-dd HH24:MI:SS')) OR Dur1.dem_RetryCount < 1) AND Dur1.dem_SentStatus = 0 AND (Dur1.dem_Active = 1) AND (Dur1.dem_PurgeState = 0) AND (Dur1.dem_PartitionNumber in (10,20)) ORDER BY Dur1.dem_RetryCount ASC, Dur1.dem_TimeCreated ASC

(2) Records in composing state for a given day 
select count(*) from DurableEmailTab where DEM_ProcessingNode like 'Composing%' and dem_sentstatus = 0 and dem_timeCreated BETWEEN Date('2013-05-07 00:00:00 PDT') AND Date('2013-05-07 23:59:00 PDT')

(3) Records owned by a task node but not moving 
SELECT * FROM DurableEmailTab WHERE DEM_SentStatus = FALSE AND DEM_ProcessingNode not like '%Composing%' AND dem_timecreated = dem_timeupdated AND DEM_retrycount=0 and DEM_ProcessingNode='TaskCXML10220601'

(4) Find emails which are pending and have file attachments
select PartitionNumber, Count(1) from ariba.app.util.DurableEmail where FileAttachments is not null and TimeCreated >= Date('2013-10-02 13:30 PDT') and SentStatus = false group by PartitionNumber

Run in each schema individually: SELECT DEM_ProcessingNode, count(*) FROM DurableEmailTab WHERE DEM_SentStatus = FALSE AND DEM_ProcessingNode not like '%Composing%' AND dem_timecreated = dem_timeupdated AND DEM_retrycount=0 GROUP BY DEM_ProcessingNode

(5) Monitoring query
SELECT substr(DEM_ProcessingNode, 1, 10) as Owner, COUNT(*) FROM DurableEmailTab WHERE DEM_SentStatus = 0 and dem_RetryCount < 96 -- unsent and active
and (dem_TimeUpdated <= trunc(sysdate) - 1) and dem_Active = 1 and dem_PurgeState = 0 GROUP BY substr(DEM_ProcessingNode, 1, 10); -- trim to 10 chars, to gather all Composing ones into 1 group

The above query would return 3 type of results which you only need 2. As I mentioned before, with this query you would get
1) # of unsent composing emails - all grouped into 1 count (composing state: Owner column = "Composing-")
2) # of unprocessed emails waiting to be processed by task node mailer (pending emails: Owner column = empty string)
3) # of to be sent emails already owned by a task node mailer

::Mark:: Scheduled Tasls
-------------------------
(1) Which schedule task are running, Run in system.privileged
select st, st.TaskName, st.NodeName from ariba.base.server.core.ScheduledTaskStatus st where st.StartTime > Date ('2013-08-21 19:55:00 PDT') and st.StartTime < Date ('2013-08-21 20:05:00 PDT') and st.EndTime is null

::Mark:: Realms
---------------
Get feature deails: select r, r.Id, r.Name, r.Features.UniqueName from RealmProfile r

::Mark:: Users
--------------
(1) Get password adapter details 
select u, u.Name, u.UniqueName, u.PasswordAdapter, u.AdapterSource, u.PartitionNumber from ariba.user.core.User u where u.UniqueName = 'SourcingSupportDeskAdmin' and PasswordAdapter = 'PasswordAdapter1'

(2) User mismatch with time clauses 
select count(1) from usertab where us_partitionnumber = 3280 and us_user not in (select rootid from us_usertab where cus_partitionnumber = 3280 and CUS_CREATED < Date('2011-12-16 PST')) and US_TIMECREATED < Date('2011-12-16 PST')

(3) Users without approvers 
select US__U_PSFINNAME, count(US__U_PSFINNAME) from usertab where us_user in (select AP_PREVIOUSSAFEAPPROVALR from Approvabletab where ap_partitionnumber = 3280 and AP_PREVIOUSSAFEAPPROVALR not in (select rootid from us_usertab where cus_partitionnumber = 3280)) and us_partitionnumber = 3280 group by US__U_PSFINNAME
select u.PartitionNumber, u.PasswordAdapter, count(*) from ariba.user.core.User u group by u.PartitionNumber, u.PasswordAdapter

(4) Get login/logout metrics for a given customer, 8906 corresponds to login and 8907 is logout
select this, NodeName, IPAddress, TimeCreated, TimeUpdated, pp.Param1, ResourceId from StaticAuditInfo join PersistedParameters pp using Parameters where (ResourceId = 8907 or ResourceId = 8906) and TimeCreated > Date ('2012-11-11 00:00:00 PST') order by TimeCreated asc

::Mark:: Misc
--------------
(1) Rownum
SELCT FROM (SELECT m, rownum AS r FROM (SELECT ms_messageid,ms_statevalue,ms_timeupdated,ms_consumer,rownum FROM messagestatustab WHERE ms_queueid = 1000 AND ms_statevalue = 1 AND ms_timeupdated < TO_DATE('2012-06-20 18:08:08', 'YYYY-MM-DD HH24:MI:SS') ORDER BY ms_consumer) m ) WHERE r BETWEEN 1 AND 1000;

select from long string: select s, s.TaskName, s.NodeName, s.PartitionNumber, s.Status, count( ) from ScheduledTaskStatus s left outer join LongString l using s.StatusMessage left outer joinLongStringElement e using l.Strings group by s, s.TaskName, s.NodeName, s.PartitionNumber, s.Status having count() >

::Mark:: Organizations
----------------------
select o.PartitionNumber, p.Domain, p.Value, count()from ariba.user.core.Organization o include inactive join ariba.user.core.OrganizationID i using o.OrganizationID join ariba.user.core.OrganizationIDPart p using i.Ids group by o.PartitionNumber, p.Domain, p.Value having count() > 1

select o, o.Active, o.Name, o.SystemID, p.Domain, p.Value from ariba.user.core.Organization o include inactive join OrganizationID i using o.OrganizationID join OrganizationIDPart p using i.Ids where p.Value = '1984427'

select p.rootid, p.myid, o.ORG_SYSTEMID, o.C1Y7POAV_PRMRYSTRNG_NA, p.OIDP_DOMAIn, p.oidp_value from us_organizationidparttab p, us_organizationtab o where o.rootid = p.rootid and o.org_systemid in ('ACM_3923124','ACM_3923209','2865912','2133759','Buyer_2905816','2025883','ACM_7333716','ACM_7697882','Buyer_5042560','Buyer_5042552','ACM_10253252') and o.org_partitionnumber = 9620 order by 1,2

select o, o.Name, o.SystemID from ariba.user.core.Organization o include inactive where o.SystemID in ('ACM_3923124','ACM_3923209','2865912','2133759','Buyer_2905816','2025883','ACM_7333716','ACM_7697882','Buyer_5042560','Buyer_5042552','ACM_10253252')
Click on each records, go to Organization ID, Base vector

select o, o.Active, o.Name, o.SystemID, p.Domain, p.Value from ariba.user.core.Organization o include inactive join OrganizationID i using o.OrganizationID join OrganizationIDPart p using i.Ids

::Mark::  Invoice Reconcilliation
---------------------------------
(1) IR Total
select count(IR) from ariba.invoicing.core.InvoiceReconciliation as IR

(2) IR unprocessed (reconciling or approving)
select count(IR) from ariba.invoicing.core.InvoiceReconciliation as IR where (IR.StatusString='Reconciling' or IR.StatusString='Approving')

(3) IR processed today
select count(IR) from ariba.invoicing.core.InvoiceReconciliation as IR where (IR.StatusString='Paying' or IR.StatusString='Paid') and (currentdate()-IR.ApprovedDate) <= 1

(4) IR total processed (paying or paid)
select count(IR) from ariba.invoicing.core.InvoiceReconciliation as IR where (IR.StatusString='Paying' or IR.StatusString='Paid')

(5) PCCR Total
select count(PCCR) from ariba.charge.core.ChargeReconciliation as PCCR

(6) PCCR unprocessed (reconciling or approving)
select count(PCCR) from ariba.charge.core.ChargeReconciliation as PCCR where (PCCR.StatusString='Reconciling' or PCCR.StatusString='Approving')

(7) PCCR processed today
select count(PCCR) from ariba.charge.core.ChargeReconciliation as PCCR where (PCCR.StatusString='Paying' or PCCR.StatusString='Paid') and (currentdate()-PCCR.ApprovedDate) <= 1

(8) PCCR total processed (paying or paid)
select count(PCCR) from ariba.charge.core.ChargeReconciliation as PCCR where (PCCR.StatusString='Paying' or PCCR.StatusString='Paid')

(9) InvoiceReconciliation Exceptions
select ie."Type".UniqueName, count(distinct ir) from ariba.invoicing.core.InvoiceReconciliation ir join ariba.invoicing.core.InvoiceReconciliationLineItem irli using ir.LineItems join ariba.invoicing.core.InvoiceException ie using irli.Exceptions where ir.StatusString='Reconciling' group by ie."Type".UniqueName union select ie."Type".UniqueName, count(ir) from ariba.invoicing.core.InvoiceReconciliation ir join ariba.invoicing.core.InvoiceException ie using ir.Exceptions where ir.StatusString='Reconciling' group by ie."Type".UniqueName

(10) ChargeReconciliation Exceptions 
select ce."Type".UniqueName, count(distinct pccr)from ariba.charge.core.ChargeReconciliation pccr join ariba.charge.core.ChargeReconciliationLineItem pccrli using pccr.LineItems join ariba.charge.core.ChargeException ce using pccrli.Exceptions where pccr.StatusString='Reconciling' group by ce."Type".UniqueName union select ce."Type".UniqueName, count(pccr) from ariba.charge.core.ChargeReconciliation pccr join ariba.charge.core.ChargeException ce using pccr.Exceptions where pccr.StatusString='Reconciling' group by ce."Type".UniqueName 

::Mark:: Data Pull related
---------------------------
select TimeCreated, TimeStarted,TimeCompleted, * from AnalysisBgWork where SchemaName='Star.Shared.Schema09' and State=3 order by TimeCreated desc

select  * from AnalysisDBSchema where SchemaName='Star.Shared.Schema09':w

select a, a.SchemaName, a.State, a.TimeScheduled from AnalysisBgWork a where a.State in (0,4) and a.NodeName='' order by a.State DESC, a.TimeScheduled ASC

::Mark:: General DB
--------------------
(1) Getting explain plan
explain plan for select ename from emp where ename = :x ;
SELECT * FROM table(dbms_xplan.display);

(2) Create Duplicate table
Create table <output_table> parallel (degree 4) as select * from <input_table> append;

(3) Execute Stats
EXEC DBMS_STATS.gather_table_stats('BYRLIVE19','DURABLEEMAILTAB',estimate_percent=>20,cascade=>TRUE);

(4) Stored procedure to cleanup durable emails
//ariba/buyer/migrate/release/generic/2.85.1+/etc/sql/dbpatches/12s2DF_1-CHS0BX_08_12_2013/
Executing the stored procedure
SQL> SPOOL /tmp/amexdf2.log
SQL> SET TIMING ON;
SQL> SET SERVEROUTPUT ON;
SQL> @/tmp/cleanup_script.sql
SQL> execute CleanupDurableEmail;
