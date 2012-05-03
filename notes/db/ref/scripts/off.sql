

#job_type (upload=1, xform=2, download=3)
#usr_filetype (csv=1, excel xml=2, generic xml=3)
#job_status (created=0, pending=1, processing=2, completed_no_err=3, rejected=4, completed_with_err=5, 
#            invalid_header=6, empty_download=7, rejected_unsupported_format=8, file_upload_in_progress=9)

# Get the count of completed jobs of a certain size after a certain date.
select count(*) from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and b.terms > 3500 and a.cr_date >= to_date('15-10-2009','DD-MM-YYYY') order by a.cr_date desc;
 
# Get the sorted processing times for completed jobs of a certain size after a certain date.
select (a.last_upd - a.job_start_time) times, a.job_start_time, b.terms, a.job_status,a.bulk_job_id from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and b.terms > 1500 and b.terms < 3000 and a.cr_date >= to_date('15-10-2009','DD-MM-YYYY') order by a.cr_date desc;
select (a.last_upd - a.job_start_time) times, a.job_start_time, b.terms, a.job_status,a.bulk_job_id from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and b.terms > 10000 and b.terms < 35000 and a.cr_date >= to_date('16-10-2009','DD-MM-YYYY') order by times;
select (a.last_upd - a.job_start_time) times, a.job_start_time, b.terms, a.job_status,a.bulk_job_id from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and b.terms > 10000 and b.terms < 35000 and a.cr_date >= to_date('16-10-2009','DD-MM-YYYY') and a.cr_date < to_date('17-10-2009','DD-MM-YYYY')order by times;
 
# Get the completed jobs of particular type for a particular account .
select * from cmpgn.bulk_job where acct_id = 22030780374 and job_status = 3 and job_type = 3 order by cr_date desc;



##-----------Bulk stats during load window----------- ##

# Total upload jobs
select count(*) from cmpgn.bulk_job a 
where job_type=1 and usr_filetype=3 and a.cr_date >= to_date('12-1-2010 8','DD-MM-YYYY hh24') 
and a.cr_date <= to_date('12-1-2010 20','DD-MM-YYYY hh24');

# Total download jobs
select count(*) from cmpgn.bulk_job a 
where job_type=3 and a.cr_date >= to_date('12-1-2010 8','DD-MM-YYYY hh24') and a.cr_date <= to_date('12-1-2010 20','DD-MM-YYYY hh24');

# Avg, min, max for wait and import time
select b.terms, count(*),
round(avg ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) avg_waittime, 
round(min ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) min_waittime, 
round(max ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) max_waittime, 
round(avg ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) avg_importtime,
round(min ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) min_importtime,
round(max ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) max_importtime
from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b 
where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and (a.job_status = 3 or a.job_status = 5)
and a.cr_date >= to_date('02-2-2010 8','DD-MM-YYYY hh24') and a.cr_date <= to_date('04-2-2010 20','DD-MM-YYYY hh24') 
group by b.terms order by b.terms;

# Avg, min, max for wait and export time
select b.terms, count(*),
round(avg ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) avg_waittime, 
round(min ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) min_waittime, 
round(max ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) max_waittime, 
round(avg ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) avg_exporttime,
round(min ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) min_exporttime,
round(max ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) max_exporttime
from cmpgn.bulk_job a, cmpgn.bulk_download_stats b 
where job_type=3 and a.bulk_job_id = b.bulk_job_id and a.bulk_job_id = b.bulk_job_id and (a.job_status = 3 or a.job_status = 5)
and a.cr_date >= to_date('12-1-2010 8','DD-MM-YYYY hh24') and a.cr_date <= to_date('12-1-2010 20','DD-MM-YYYY hh24') 
group by b.terms order by b.terms;

# Raw upload data
select (a.job_start_time - a.cr_date) waittime, (a.last_upd - a.job_start_time) importtime, a.cr_date, a.job_start_time, 
b.terms, a.job_status,a.bulk_job_id 
from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id 
and a.cr_date >= to_date('11-1-2009 13','DD-MM-YYYY hh24') and a.cr_date <= to_date('2-11-2009 13','DD-MM-YYYY hh24') 
order by b.terms, waittime, importtime;

# Raw download data
select (a.job_start_time - a.cr_date) waittime, (a.last_upd - a.job_start_time) exporttime, a.cr_date, a.job_start_time, 
b.terms, a.job_status,a.bulk_job_id 
from cmpgn.bulk_job a, cmpgn.bulk_download_stats b where job_type=3 and a.bulk_job_id = b.bulk_job_id 
and a.cr_date >= to_date('1-11-2009 13','DD-MM-YYYY hh24') and a.cr_date <= to_date('2-11-2009 13','DD-MM-YYYY hh24') 
order by b.terms, waittime, exporttime;

##-----------Bulk stats during load window----------- ##





select
round(((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) waittime,
round(((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) importtime,
b.*
from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b 
where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and (a.job_status = 3 or a.job_status = 5)
and a.cr_date >= to_date('02-2-2010 8','DD-MM-YYYY hh24') and a.cr_date <= to_date('04-2-2010 20','DD-MM-YYYY hh24') 
and b.bulk_job_id = 454793502;

select b.terms, count(*),
round(avg ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) avg_waittime, 
round(min ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) min_waittime, 
round(max ((cast(a.job_start_time as date) - cast(a.queue_start_time as date)) * 24*60*60),0) max_waittime, 
round(avg ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) avg_importtime,
round(min ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) min_importtime,
round(max ((cast(a.last_upd as date) - cast(a.job_start_time as date)) * 24*60*60),0) max_importtime
from cmpgn.bulk_job a, cmpgn.bulk_upload_stats b 
where job_type=1 and usr_filetype=3 and a.bulk_job_id = b.bulk_job_id and (a.job_status = 3 or a.job_status = 5)
and a.cr_date >= to_date('02-2-2010 8','DD-MM-YYYY hh24') and a.cr_date <= to_date('04-2-2010 20','DD-MM-YYYY hh24') 
group by b.terms order by b.terms;




---dis bulk----


select queued_tmstmp from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%'  order by queued_tmstmp desc;

# Total count in a time range
select count(*), job_name, state, pickedup_by from sched.exec_job_details 
where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and 
queued_tmstmp > to_date('15-11-2010 10:00am', 'DD-MM-YYYY hh:mi am') and 
queued_tmstmp < to_date('23-11-2010 10:00am', 'DD-MM-YYYY hh:mi am')
group by job_name, state, pickedup_by
order by job_name, pickedup_by desc;
# Timings
select (completed_tmstmp - pickedup_tmstmp) from sched.exec_job_details 
where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT_IMPORT%' and state = 200 and
queued_tmstmp > to_date('15-11-2010 10:00am', 'DD-MM-YYYY hh:mi am') and 
queued_tmstmp < to_date('23-11-2010 10:00am', 'DD-MM-YYYY hh:mi am')
order by queued_tmstmp desc;

select  ((SUBSTR((completed_tmstmp - pickedup_tmstmp),INSTR((completed_tmstmp - pickedup_tmstmp), ' ')+7,2)) +
((SUBSTR((completed_tmstmp - pickedup_tmstmp),INSTR((completed_tmstmp - pickedup_tmstmp), ' ')+4,2))*60) +
((SUBSTR((completed_tmstmp - pickedup_tmstmp),INSTR((completed_tmstmp - pickedup_tmstmp), ' ')+1,2))*3600)) diff1 
from sched.exec_job_details 
where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT_EXPORT%' and state = 200 and
queued_tmstmp > to_date('15-11-2010 10:00am', 'DD-MM-YYYY hh:mi am') and 
queued_tmstmp < to_date('23-11-2010 10:00am', 'DD-MM-YYYY hh:mi am')
order by queued_tmstmp desc;
#(completed_tmstmp - pickedup_tmstmp) diff2 


# Deletes
#elete from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=100;
#elete from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=0;
#ommit;


# Misc
select * from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=100  order by queued_tmstmp desc;
select * from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=0  order by queued_tmstmp desc;
select * from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=100  and pickedup_by ='ac4-stg2scheduler-002.ysm.ac4.yahoo.com' order by queued_tmstmp desc;
select * from sched.exec_job_details where JOB_GROUP='BULK' and JOB_NAME  like 'BULK_PLACEMENT%' and state=100  and pickedup_by ='ac4-stg2scheduler-001.ysm.ac4.yahoo.com' order by queued_tmstmp desc;


-- cpt -- 

##-----------CPT stats during load window----------- ##

# Total convert jobs
select count(*) from cmpgn.cpt_job a
where a.cr_date >= to_date('28-10-2009 05','DD-MM-YYYY hh24') and a.cr_date <= to_date('28-10-2009 8','DD-MM-YYYY hh24');

# Total failed jobs
select count(*) from cmpgn.cpt_job a
where a.cr_date >= to_date('28-10-2009 05','DD-MM-YYYY hh24') and a.cr_date <= to_date('28-10-2009 8','DD-MM-YYYY hh24')
and job_status = 91;

# Avg, min, max for wait and convert time
select a.usr_filename, count(*),
round(avg ( ((cast(a.job_start_time as date) - cast(a.cr_date as date)) * 24*60*60) - a.upload_time_taken) ,0) avg_waittime, 
round(min ( ((cast(a.job_start_time as date) - cast(a.cr_date as date)) * 24*60*60) - a.upload_time_taken) ,0) min_waittime, 
round(max ( ((cast(a.job_start_time as date) - cast(a.cr_date as date)) * 24*60*60) - a.upload_time_taken) ,0) max_waittime, 
round(avg (a.total_conv_imp_time),0) avg_converttime, 
round(min (a.total_conv_imp_time),0) min_converttime, 
round(max (a.total_conv_imp_time),0) max_converttime
from cmpgn.cpt_job a
where a.cr_date >= to_date('28-10-2009 05','DD-MM-YYYY hh24') and a.cr_date <= to_date('28-10-2009 8','DD-MM-YYYY hh24') 
and (a.job_status = 40 or a.job_status = 41 or a.job_status = 91)
group by a.usr_filename, a.CMPGN_DUP_PREF
order by a.usr_filename desc;

# Raw convert data
select a.usr_filename, a.cr_date, a.job_status, a.upload_time_taken, a.convert_time_taken, a.total_conv_imp_time, a.convert_option, a.cmpgn_dup_pref, a.cpt_usr_pref_adv_options_flag from cmpgn.cpt_job a
where a.cr_date >= to_date('28-10-2009 05','DD-MM-YYYY hh24') and a.cr_date <= to_date('28-10-2009 8','DD-MM-YYYY hh24');

##-----------CPT stats during load window----------- ##

-- pod --

select host_ip_addr, port from pm.pod_vip where svr_role_id = 40;

select * from PM.SVR where Name like '%yahoo.com%';

INSERT INTO PM.SVR ( SVR_ID, NAME, ACTIVE_FLG, COLO_ID, CR_DATE, LAST_UPD, EXT_NAME ) VALUES (25041980, 'nothingcan-lx.eglbp.corp.yahoo.com', 1, 1, TO_TIMESTAMP('1/1/0001 12:00:00.000 AM','fmMMfm/fmDDfm/YYYY fmHH12fm:MI:SS.FF AM'), TO_TIMESTAMP('1/1/2006 12:00:00.000 AM','fmMMfm/fmDDfm/YYYY fmHH12fm:MI:SS.FF AM')
, NULL); 

select * from PM.SVR_ROLE_MAP where SVR_ID = 25041980;

INSERT INTO PM.SVR_ROLE_MAP (SVR_ROLE_MAP_ID,POD_ID,SVR_ID,SVR_ROLE_ID,DB_INSTANCE_ID,CR_DATE,LAST_UPD) VALUES (25041980, 1, 25041980, 32, NULL, SYSDATE, SYSDATE);

