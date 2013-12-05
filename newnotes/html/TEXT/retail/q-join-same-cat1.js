document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT * \n\
FROM product \n\
WHERE category = ( SELECT category \n\
                   FROM product \n\
                   WHERE name = "moto-defy"\n\
                 );\
    </code></pre> \n\
');
