document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT * \n\
FROM sales \n\
LEFT JOIN customer ON sales.login = customer.login;\n\
\n\
* For every row in sales, get matching row in customer\n\
* For "invalid" row in sales, notice NULL data from customer since \n\
  invalid doesn\'t exist in customer table\
    </code></pre> \n\
');
