document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT sales.id Transaction, sales.time Date, customer.name Customer, \n\
       product.name Product, sales.quantity, product.price Price, \n\
       manufacturer.name Manufacturer, category.category Category\n\
FROM sales\n\
JOIN product ON product.id = sales.product\n\
JOIN manufacturer ON product.manufacturer = manufacturer.id\n\
JOIN category ON product.category = category.id\n\
JOIN customer ON sales.login = customer.name;\
    </code></pre> \n\
');
