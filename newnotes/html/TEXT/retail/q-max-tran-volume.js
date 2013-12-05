document.write(' \n\
    <pre><code data-trim contenteditable> \n\
SELECT login, count(login) \n\
FROM sales \n\
GROUP BY login \n\
HAVING count(login) =  \n\
       ( SELECT max(cnt) \n\
         FROM ( SELECT login, count(login) cnt \n\
                FROM sales \n\
                GROUP BY login \n\
              ) as p \n\
       ); \n\
\n\
* Get transactions per login-  \n\
  select login, count(login) cnt from sales group by login order by cnt desc \n\
* Fetch max of count by using inner query -  \n\
  select MAX(cnt) from (select login, count(login) cnt from sales \n\
                        group by login) as p \n\
* Use same query and having clause to compare with previously fetched max \
     </code></pre> \n\
');
