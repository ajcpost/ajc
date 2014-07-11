document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT p2.name, sales.product, SUM(quantity) total \n\
FROM sales \n\
JOIN product p2 on p2.id = sales.product \n\
GROUP BY sales.product \n\
HAVING total = ( SELECT MIN(total) \n\
                 FROM ( SELECT product, SUM(quantity) total \n\
                        FROM sales GROUP BY product \n\
                      ) AS p \n\
               ); \
    </code></pre> \n\
');
