
# Task 1

CREATE DATABASE users_adverts;
CREATE TABLE users (
date DATE,
user_id VARCHAR(100),
view_adverts INT);


SELECT * FROM users;

#1 Question (Напишите запрос SQL, выводящий одним числом количество уникальных пользователей в этой таблице в период с 2023-11-07 по 2023-11-15).
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM users
WHERE date BETWEEN '2023-11-07' AND '2023-11-15';


#2 Question (Определите пользователя, который за весь период посмотрел наибольшее количество объявлений).
SELECT user_id, MAX(view_adverts) AS max_ad
FROM users
GROUP BY user_id
ORDER BY max_ad DESC
LIMIT 1;


#3 Question (Определите день с наибольшим средним количеством просмотренных рекламных объявлений на пользователя, но учитывайте только дни с более чем 500 уникальными пользователями).
SELECT date, COUNT(DISTINCT user_id) AS unique_user_count, AVG(view_adverts) AS avg_views
FROM users
GROUP BY date
HAVING COUNT(DISTINCT user_id) > 500
ORDER BY avg_views DESC;


#4 Question (Напишите запрос возвращающий LT (продолжительность присутствия пользователя на сайте) по каждому пользователю. Отсортировать LT по убыванию).
SELECT user_id, COUNT(DISTINCT date) AS LT  
FROM users
GROUP BY user_id
ORDER BY COUNT(DISTINCT date) DESC;


#5 Question (Для каждого пользователя подсчитайте среднее количество просмотренной рекламы за день, а затем выясните, у кого самый высокий средний показатель среди тех, кто был активен как минимум в 5 разных дней).

SELECT date, user_id, ROUND(AVG(view_adverts)) AS avg_adv, IF( user_id >= '5', 'more', 'less') AS act_day
FROM users
GROUP BY date, user_id
HAVING act_day = 'more' AND avg_adv NOT LIKE '0'
ORDER BY avg_adv DESC;
 
 
 # Task 2

 DROP TABLE t_tab1;
 DROP TABLE t_tab2;
 
 CREATE DATABASE mini_project;
 CREATE TABLE T_TAB1 (
 ID INT PRIMARY KEY AUTO_INCREMENT,
 GOODS_TYPE VARCHAR (100),
 QUANTITY INT,
 AMOUNT INT,
 SELLER_NAME VARCHAR (100) NOT NULL);
 
 CREATE TABLE T_TAB2 (
 ID INT PRIMARY KEY AUTO_INCREMENT,
 NAME VARCHAR (100) NOT NULL,
 SALARY INT,
 AGE INT);
 
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('mobile phone', '2', '40000', 'Mike');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('keyboard', '1', '10000', 'Mike');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('mobile phone', '1', '50000', 'Jane');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('monitor', '1', '110000', 'Joe');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('monotor', '2', '80000', 'Jane');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('mobile phone', '1', '130000', 'Joe');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('mobile phone', '1', '60000', 'Anna');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('printer', '1', '90000', 'Anna');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('keyboard', '2', '10000', 'Anna');
 Insert into t_tab1 (goods_type, quantity, amount, seller_name) values ('printer', '1', '80000', 'Mike');
 Insert into t_tab2 (name, salary, age) values ('Anna', '110000', '27');
 Insert into t_tab2 (name, salary, age) values ('Jane', '80000', '25');
 Insert into t_tab2 (name, salary, age) values ('Mike', '120000', '25');
 Insert into t_tab2 (name, salary, age) values ('Joe', '70000', '24');
 Insert into t_tab2 (name, salary, age) values ('Rita', '120000', '29');
 
 
 SELECT * FROM T_TAB1;
 SELECT * FROM T_TAB2;
 
 #1 Question (Напишите запрос, который вернёт список уникальных категорий товаров (GOODS_TYPE). Какое количество уникальных категорий товаров вернёт запрос?)
 SELECT DISTINCT GOODS_TYPE
 FROM T_TAB1;
 
 #2 Question (Напишите запрос, который вернет суммарное количество и суммарную стоимость проданных мобильных телефонов. Какое суммарное количество и суммарную стоимость вернул запрос?)
 SELECT GOODS_TYPE, SUM(QUANTITY) AS sum_q, SUM(AMOUNT) AS sum_a
 FROM T_TAB1
 WHERE GOODS_TYPE LIKE 'mobile phone'
 GROUP BY GOODS_TYPE;
 
 #3 Question (Напишите запрос, который вернёт список сотрудников с заработной платой > 100000. Какое кол-во сотрудников вернул запрос?)
 SELECT * 
 FROM T_TAB2
 WHERE SALARY > 100000;
 
 #4 Question (Напишите запрос, который вернёт минимальный и максимальный возраст сотрудников, а также минимальную и максимальную заработную плату)
 SELECT MAX(SALARY), MIN(SALARY), MAX(AGE), MIN(AGE)
 FROM T_TAB2;
 
 #5 Question (Напишите запрос, который вернёт среднее количество проданных клавиатур и принтеров)
 SELECT GOODS_TYPE, ROUND(AVG(QUANTITY),2)
 FROM T_TAB1
 WHERE GOODS_TYPE IN  ('keyboard', 'printer')
 GROUP BY GOODS_TYPE;
 
 #6 Question (Напишите запрос, который вернёт имя сотрудника и суммарную стоимость проданных им товаров)
 SELECT SELLER_NAME, SUM(AMOUNT)
 FROM T_TAB1
 GROUP BY SELLER_NAME;
 
 #7 Question (Напишите запрос, который вернёт имя сотрудника, тип товара, кол-во товара, стоимость товара, заработную плату и возраст сотрудника MIKE)
 SELECT S.SELLER_NAME, S.GOODS_TYPE, S.QUANTITY, S.AMOUNT, N.SALARY, N.AGE
 FROM T_TAB1 S
 JOIN T_TAB2 N ON N.NAME = S.SELLER_NAME
 WHERE S.SELLER_NAME = 'MIKE';
 
 #8 Question (Напишите запрос, который вернёт имя и возраст сотрудника, который ничего не продал. Сколько таких сотрудников?)
 SELECT  S.SELLER_NAME, N.AGE
 FROM T_TAB1 S
 JOIN T_TAB2 N ON N.NAME = S.SELLER_NAME
 WHERE AMOUNT = 0;
 
 #9 Question (Напишите запрос, который вернёт имя сотрудника и его заработную плату с возрастом меньше 26 лет? Какое количество строк вернул запрос?)
 SELECT NAME, SALARY
 FROM T_TAB2
 WHERE age < 26;
 
 #10 Question ( Сколько строк вернёт следующий запрос: SELECT * FROM T_TAB1 t JOIN T_TAB2 t2 ON t2.name = t.seller_name WHERE t2.name = 'RITA';
SELECT COUNT(*) FROM T_TAB1 t 
JOIN T_TAB2 t2 ON t2.name = t.seller_name 
WHERE t2.name = 'RITA'; 


 