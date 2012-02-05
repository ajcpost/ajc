
----- find customer who has done max transactions by volume 
---------------------------------------------------------------------------------------------------------------

## Step 1, get count of transactions per login
select login, count(login) cnt from sales group by login order by cnt desc;

## Step 2, first get a max of count
select MAX(cnt) from (select login, count(login) cnt from sales group by login) as p;
-- Multiple rows may have same count so MAX() function may return more than one rows.
-- Due to this a direct "select login, MAX(cnt)" will not work.
-- Due to this, one can not apply limit or TOP clauses and get direct answers.

## Step 3, Round about way to get the answer by comparing
select login, count(login) from sales group by login having count(login) = (select max(cnt) from (select login, count(login) cnt from sales group by login) as p1);


----- find customer who has done max transactions by price
---------------------------------------------------------------------------------------------------------------

## Step 1, get price info by joining with Product table
select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id;

## Step 2, sum individual amounts to compute total per login
select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p1 group by login;

## Step 3, get max of total
select MAX(total) from (select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p group by login) as p1;

## Do the round about way of comparing
select login, SUM(amount) from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product=product.id) as p group by login having SUM(amount) = (select MAX(total) from (select login, SUM(amount) total from (select login, product.name, (quantity * product.price) amount, quantity from sales join product on sales.product = product.id) as p1 group by login) as p2);




----- find products which are not sold 
---------------------------------------------------------------------------------------------------------------

select * from product where id not in (select distinct product from sales);



----- find products which are not sold and display their category, manufacurer
---------------------------------------------------------------------------------------------------------------

select pd.name, pd.price, cat.category, manf.name from product pd, category cat, manufacturer manf where pd.category = cat.id and pd.manufacturer = manf.id and pd.id not in (select distinct product from sales);



----- find a product which is least sold
---------------------------------------------------------------------------------------------------------------

## Step 1, get sum of all the product quantities sold
select product, SUM(quantity) total from sales group by product;

## Step 2, Find min
select MIN(total) from (select product, SUM(quantity) total from sales group by product) as p;
-- Multiple rows may have same count so MIN() function may return more than one rows.
-- Due to this a direct "select product, MIN(total)" will not work.
-- Due to this, one can not apply limit or TOP clauses and get direct answers.

## Step 3, Round about way to get the answer by comparing
select product, SUM(quantity) total from sales group by product having total = (select MIN(total) from (select product, SUM(quantity) total from sales group by product) as p);


----- find a products salesd by aj
---------------------------------------------------------------------------------------------------------------

select * from product where id in (select distinct product from sales where login = 'aj');
