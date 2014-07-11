document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT login, sum(quantity * product.price) total \n\
FROM sales \n\
JOIN product ON sales.product = product.id \n\
GROUP BY login \n\
HAVING total = ( SELECT MAX(total) \n\
                 FROM ( SELECT login, sum(quantity * product.price) total \n\
                        FROM sales \n\
                        JOIN product ON sales.product = product.id \n\
                        GROUP BY login \n\
                      ) AS p \n\
               ); \n\
\n\
* Spend by each customer - select login, sum(quantity*product.price) total \n\
  from sales join product on sales.product = product.id group by login \n\
* Fetch max by using inner query - select MAX(total) from (above query) \n\
* Use same query and having clause to compare with previously fetched max \
    </code></pre> \n\
');
