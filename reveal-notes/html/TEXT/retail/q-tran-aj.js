document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT * \n\
FROM product \n\
WHERE id in ( SELECT distinct product \n\
              FROM sales \n\
              WHERE login = "aj" \n\
            ); \n\
    </code></pre> \
');
