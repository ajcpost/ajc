document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT login, sum(quantity * product.price) total \n\
FROM sales \n\
JOIN product ON sales.product = product.id and \n\
                sales.product in ( SELECT id \n\
                                   FROM product \n\
                                   WHERE name like "moto%") \n\
GROUP BY login \n\
HAVING total = ( SELECT MAX(total) \n\
                 FROM ( SELECT login, sum(quantity * product.price) total \n\
                        FROM sales \n\
                        JOIN product ON sales.product = product.id and \n\
                                     sales.product in ( SELECT id \n\
                                                        FROM product \n\
                                                        WHERE name like "moto%") \n\
                        GROUP BY login \n\
                      ) AS p \n\
               ); \n\
 \n\
* Pretty much same as previous slide, extra addition is in the join condition \
     </code></pre> \n\
');
