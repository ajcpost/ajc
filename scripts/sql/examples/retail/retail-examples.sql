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
SELECT login, count(login) 
FROM sales 
GROUP BY login 
HAVING count(login) =  
       ( SELECT max(cnt) 
         FROM ( SELECT login, count(login) cnt 
                FROM sales 
                GROUP BY login 
              ) as p 
       ); 


# customer with max total pay - wrong
# -----------------------------------
SELECT login, sum(quantity * product.price) total 
FROM sales 
JOIN product ON sales.product = product.id 
GROUP BY login 
ORDER BY total desc;


# customer with max total pay - right
# -----------------------------------
SELECT login, sum(quantity * product.price) total 
FROM sales 
JOIN product ON sales.product = product.id 
GROUP BY login 
HAVING total = ( SELECT MAX(total) 
                 FROM ( SELECT login, sum(quantity * product.price) total 
                        FROM sales 
                        JOIN product ON sales.product = product.id 
                        GROUP BY login 
                      ) AS p 
               ); 


# customer with max total pay - product list
# ------------------------------------------
SELECT login, sum(quantity * product.price) total 
FROM sales 
JOIN product ON sales.product = product.id and 
                sales.product in (select id from product where name like "moto%") 
GROUP BY login 
HAVING total = ( SELECT MAX(total) 
                 FROM ( SELECT login, sum(quantity * product.price) total 
                        FROM sales 
                        JOIN product ON sales.product = product.id and 
                                     sales.product in (select id from product where name like "moto%") 
                        GROUP BY login 
                      ) AS p 
               ); 


# unsold products
# ---------------
SELECT pd.name, pd.price, cat.category, manf.name 
FROM product pd, category cat, manufacturer manf 
WHERE pd.category = cat.id and 
      pd.manufacturer = manf.id and 
      pd.id not in (SELECT distinct product from sales); 



# least sold products
# -------------------
SELECT p2.name, sales.product, SUM(quantity) total 
FROM sales 
JOIN product p2 on p2.id = sales.product 
GROUP BY sales.product 
HAVING total = ( SELECT MIN(total) 
                 FROM ( SELECT product, SUM(quantity) total 
                        FROM sales GROUP BY product 
                      ) AS p 
               ); 

# products purchased by 'aj'
# --------------------------
SELECT * 
FROM product 
WHERE id in ( SELECT distinct product 
              FROM sales 
              WHERE login = "aj" 
            );


# customers who purchased same products as 'aj' - 1
# -------------------------------------------------
SELECT login 
FROM sales 
WHERE login !="aj" and 
      product in ( SELECT product 
                   FROM sales 
                   WHERE login="aj");


# customers who purchased same products as 'aj' - 2
# -------------------------------------------------
SELECT customer.login, customer.name 
FROM sales 
JOIN customer on sales.login = customer.login 
WHERE sales.login !="aj" and 
      product in ( SELECT product 
                   FROM sales 
                   WHERE login="aj");


# (big-join) details of all sales
# -------------------------------
SELECT sales.id Transaction, sales.time Date, customer.name Customer, 
       product.name Product, sales.quantity, product.price Price, 
       manufacturer.name Manufacturer, category.category Category
FROM sales
JOIN product ON product.id = sales.product
JOIN manufacturer ON product.manufacturer = manufacturer.id
JOIN category ON product.category = category.id
JOIN customer ON sales.login = customer.name;

# (self-join) products in same category - 1
# -----------------------------------------
SELECT * 
FROM product 
WHERE category = ( SELECT category 
                   FROM product 
                   WHERE name = "moto-defy"
                 );

# (self-join) products in same category - 2
# -----------------------------------------
SELECT * 
FROM product p1, product p2 
WHERE p1.category=p2.category and p2.name="moto-defy";


# (self-join) - 1
# ---------------
SELECT * 
FROM category c1 
JOIN category c2 ON (c1.category = c2.category);

# (self-join) - 2
# ---------------
SELECT * 
FROM category c1 
JOIN category c2;


# (outer-join) joining sales to customer
# --------------------------------------
SELECT * 
FROM customer 
LEFT JOIN sales ON customer.login = sales.login;

# (outer-join) joining customer to sales
# --------------------------------------
SELECT * 
FROM sales 
LEFT JOIN customer ON sales.login = customer.login;
