document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT pd.name, pd.price, cat.category, manf.name \n\
FROM product pd, category cat, manufacturer manf \n\
WHERE pd.category = cat.id and \n\
      pd.manufacturer = manf.id and \n\
      pd.id not in (SELECT distinct product from sales); \n\
    </code></pre> \
');
