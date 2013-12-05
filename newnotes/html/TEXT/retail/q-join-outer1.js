document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT * \n\
FROM customer \n\
LEFT JOIN sales ON customer.login = sales.login;\n\
\n\
* For every row in customer, get matching row in sales\n\
* For "invalid" sales record, no entry since it doesn\'t\n\
  exist in customer table\n\
* For "chris" customer, notice NULL data from sales since \n\
  chris hasn\'t purchased any product. \
    </code></pre> \n\
');
