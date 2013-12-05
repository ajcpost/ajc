use emp;

# dump output of all tables
# -------------------------
select * from employee;


# Find salary sum for all sub-ordinates
# -----------------------------------------------------
select e1.name, sum(e2.sal) from employee e1, employee e2 where e1.id = e2.manager group by e1.name;
select e1.name, sum(e1.sal) from employee e1, employee e2 where e1.id = e2.manager group by e1.name;
