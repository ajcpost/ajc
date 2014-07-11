document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT login, sum(quantity * product.price) total \n\
FROM sales \n\
JOIN product ON sales.product = product.id \n\
GROUP BY login \n\
ORDER BY total desc; \n\
\n\
* Use limit in mysql or rownum in oracle \n\
* This is wrong way because we don\'t know how many rows satisfy the \n\
  max criterion. \
     </code></pre> \n\
');
