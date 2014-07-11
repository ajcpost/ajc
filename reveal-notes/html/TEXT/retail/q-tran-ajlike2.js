document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT customer.login, customer.name \n\
FROM sales \n\
JOIN customer on sales.login = customer.login \n\
WHERE sales.login !="aj" and \n\
      product in ( SELECT product \n\
                   FROM sales \n\
                   WHERE login="aj"); \n\
\n\
* This one joins customer table, so any logins which do not exist as\n\
  customer will not show up in the final output.\n\
* The join condition can be put in the WHERE clause itself\n\
    </code></pre> \
');
