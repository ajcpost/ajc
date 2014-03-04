use retail;

# dump output of all tables
# -------------------------
select * from manufacturer;
select * from category;
select * from product;
select * from customer;
select * from sales;


# customer with max transactions by volume
# ----------------------------------------

# Step 1, get count of transactions per login
# select login, count(login) cnt from sales group by login order by cnt desc;

# Step 2, first get a max of count
# Multiple rows may have same count so MAX() function may return more than one rows. 
# Due to this a direct "select login, MAX(cnt)" will not work.
# Due to this, one can not apply limit or TOP clauses and get direct answers.
# select MAX(cnt) from (select login, count(login) cnt from sales group by login) as p;

# Step 3, Use having clause and compare to get the top row(s)
select login, count(login) from sales group by login having count(login) = (select max(cnt) from (select login, count(login) cnt from sales group by login) as p1);


# customer with max transactions by price
# ---------------------------------------

# Step 1, get price info by joining with Product table
# select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id;

# Step 2, sum individual amounts to compute total per login
# select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p1 group by login;

# Step 3, get max of total
# select MAX(total) from (select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p group by login) as p1;

# Step 4, Use having clause and compare to get the top row(s)
select login, SUM(amount) from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p group by login having SUM(amount) = (select MAX(total) from (select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product = product.id) as p1 group by login) as p2);


# details of unsold products
# --------------------------

select pd.name, pd.price, cat.category, manf.name from product pd, category cat, manufacturer manf where pd.category = cat.id and pd.manufacturer = manf.id and pd.id not in (select distinct product from sales);



# details of least sold products
# ------------------------------

# Step 1, get sum of all the product quantities sold
# select product, SUM(quantity) total from sales group by product;

# Step 2, Find min
# Multiple rows may have same count so MIN() function may return more than one rows.
# Due to this a direct "select product, MIN(total)" will not work.
# Due to this, one can not apply limit or TOP clauses and get direct answers.
# select MIN(total) from (select product, SUM(quantity) total from sales group by product) as p;

# Step 3, Use having clause and compare to get the top row(s)
# select product, SUM(quantity) total from sales group by product having total = (select MIN(total) from (select product, SUM(quantity) total from sales group by product) as p);

# Step 4,  add join to find the product name  
# Note: Will not work if join is placed at the end.
select p2.name, sales.product, SUM(quantity) total from sales inner join product p2 on p2.id = sales.product group by sales.product having total = (select MIN(total) from (select product, SUM(quantity) total from sales group by product) as p);


# details of products purchased by 'aj'
# -------------------------------------

select * from product where id in (select distinct product from sales where login = 'aj');


# details of customers who have purchased products purchased by 'aj'
# ------------------------------------------------------------------
select sales.login, customer.name from sales inner join customer on customer.login = sales.login where sales.product in (select sales.product from sales where sales.login = 'aj') and sales.login != 'aj';


# Note: Will not work if customer login is compared with s2.login. Doing a cross between s2 and customer is of no use. s1 is used to output data and hence it must be used in comparision.
# Note: Will not work if ON clause is used
select s1.login, customer.name from sales s1, sales s2, customer where s2.login='aj' and s2.product = s1.product and s1.login != 'aj' and customer.login = s1.login;


# entire details of all sales, join all 5 tables
# ----------------------------------------------
select * from manufacturer inner join product on product.manufacturer = manufacturer.id inner join category on product.category = category.id inner join sales on sales.product = product.id inner join customer on sales.login = customer.login;


# details of products who have same category as 'moto-defy' (self join)
# ---------------------------------------------------------------------
select * from product p1, product p2 where p1.category = p2.category and p2.name = 'moto-defy';
select * from product p where p.category in (select category from product where product.name = 'moto-defy');

# self join
# ---------
select * from category c1 inner join category c2 on (c1.category = c2.category);
select * from category c1 inner join category c2 on (c1.category != c2.category);



# customer and sales details
# --------------------------
select * from customer left join sales on customer.login = sales.login;


# Cartesian join, no where condition 
# ----------------------------------
select category.category, product.name from category, product;

