document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT login \n\
FROM sales \n\
WHERE login !="aj" and \n\
      product in ( SELECT product \n\
                   FROM sales \n\
                   WHERE login="aj"); \n\
 \n\
* This one doesn\'t join customer table and hence doesn\'t enforce that \n\
  login selected from sales exists in customer table. "xx" will show up. \n\
    </code></pre> \
');
