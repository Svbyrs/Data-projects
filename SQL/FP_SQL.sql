CREATE DATABASE SQL_project;

SELECT * FROM customer_info;
SELECT * FROM transactions_info;

# 1 Task
# список клиентов с непрерывной историей за год
SELECT ID_client
FROM (
    SELECT
        ID_client,
        COUNT(DATE_FORMAT(date_new, '%Y-%m')) AS active_months
    FROM transactions_info
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
    GROUP BY ID_client
) AS monthly_summary
WHERE active_months = 12;


# Средний чек по активным клиентам
SELECT
    t.ID_client,
    ROUND(AVG(t.Sum_payment), 2) AS average_check
FROM transactions_info t
WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
  AND t.ID_client IN (
    SELECT ID_client
    FROM (
        SELECT
            ID_client,
            COUNT(DATE_FORMAT(date_new, '%Y-%m')) AS active_months
        FROM transactions_info
        WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
        GROUP BY ID_client
    ) AS monthly_summary
    WHERE active_months = 12
)
GROUP BY t.ID_client;


# Средняя сумма покупок за месяц
SELECT
    t.ID_client,
    ROUND(SUM(t.Sum_payment) / 12, 2) AS average_monthly_payment
FROM transactions_info t
WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
  AND t.ID_client IN (
    SELECT ID_client
    FROM (
        SELECT
            ID_client,
            COUNT(DATE_FORMAT(date_new, '%Y-%m')) AS active_months
        FROM transactions_info
        WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
        GROUP BY ID_client
    ) AS monthly_summary
    WHERE active_months = 12
)
GROUP BY t.ID_client;



# Количество операций по клиенту
SELECT
    t.ID_client,
    COUNT(*) AS total_operations
FROM transactions_info t
WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
  AND t.ID_client IN (
    SELECT ID_client
    FROM (
        SELECT
            ID_client,
            COUNT(DATE_FORMAT(date_new, '%Y-%m')) AS active_months
        FROM transactions_info
        WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
        GROUP BY ID_client
    ) AS monthly_summary
    WHERE active_months = 12
)
GROUP BY t.ID_client;


# 2 Task
# Средняя сумма чека клиента по месяцам
SELECT
    ID_client,
    DATE_FORMAT(date_new, '%Y-%m') AS year_and_month,
    ROUND(AVG(Sum_payment), 2) AS average_check_per_month
FROM transactions_info
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY ID_client, year_and_month
ORDER BY ID_client, year_and_month;


# Среднее количество операций в месяц
SELECT
    ID_client,
    ROUND(COUNT(*) / 12, 2) AS avg_operations_per_month
FROM transactions_info
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY ID_client
ORDER BY ID_client;


# Среднее количество активных клиентов в месяц
SELECT
    ROUND(AVG(clients_per_month), 2) AS avg_clients_per_month
FROM (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS year_and_month,
        COUNT(DISTINCT ID_client) AS clients_per_month
    FROM transactions_info
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
    GROUP BY year_and_month
) AS monthly_client_counts;


# Доля клиента от общего числа операций за год
SELECT
    ID_client,
    COUNT(*) AS client_operations,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM transactions_info 
                      WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'), 4) AS operations_share
FROM transactions_info
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY ID_client
ORDER BY operations_share DESC;


# Доля суммы покупок клиента в месяце от суммы всех клиентов за месяц
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS year_and_month,
    ID_client,
    ROUND(SUM(Sum_payment) / monthly_total, 4) AS monthly_sum_share
FROM (
    SELECT *,
           SUM(Sum_payment) OVER (PARTITION BY DATE_FORMAT(date_new, '%Y-%m')) AS monthly_total
    FROM transactions_info
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
) AS t
GROUP BY ID_client, year_and_month, monthly_total
ORDER BY year_and_month, monthly_sum_share DESC;


# % соотношение M/F/NA в каждом месяце с их долей затрат
SELECT
    monthly_data.year_and_month,
    monthly_data.Gender,
    ROUND(COUNT(DISTINCT monthly_data.ID_client) / total_clients.total * 100, 2) AS percent_clients,
    ROUND(SUM(monthly_data.Sum_payment) / total_amount.total * 100, 2) AS percent_spending
FROM (
    SELECT
        DATE_FORMAT(t.date_new, '%Y-%m') AS year_and_month,
        t.ID_client,
        c.Gender,
        t.Sum_payment
    FROM transactions_info t
    JOIN customer_info c ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
) AS monthly_data

JOIN (
    SELECT
        DATE_FORMAT(t.date_new, '%Y-%m') AS year_and_month,
        COUNT(DISTINCT t.ID_client) AS total
    FROM transactions_info t
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
) AS total_clients
ON monthly_data.year_and_month = total_clients.year_and_month

JOIN (
    SELECT
        DATE_FORMAT(date_new, '%Y-%m') AS year_and_month,
        SUM(Sum_payment) AS total
    FROM transactions_info
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
    GROUP BY DATE_FORMAT(date_new, '%Y-%m')
) AS total_amount
ON monthly_data.year_and_month = total_amount.year_and_month

GROUP BY monthly_data.year_and_month, monthly_data.Gender
ORDER BY monthly_data.year_and_month, monthly_data.Gender;



# 3 Task
# Анализ клиентов по возрастным группам
WITH transactions_with_age_group AS (
    SELECT
        t.ID_client,
        t.Sum_payment,
        t.date_new,
        CASE
            WHEN c.Age IS NULL THEN 'NA'
            WHEN c.Age < 10 THEN '00-09'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
            WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS age_group,
        CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter_label
    FROM transactions_info t
    LEFT JOIN customer_info c ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
),

summary_by_age AS (
    SELECT
        age_group,
        COUNT(*) AS total_operations,
        ROUND(SUM(Sum_payment), 2) AS total_sum
    FROM transactions_with_age_group
    GROUP BY age_group
),

quarterly_summary AS (
    SELECT
        age_group,
        quarter_label,
        COUNT(*) AS operations,
        ROUND(SUM(Sum_payment), 2) AS total_sum,
        ROUND(AVG(Sum_payment), 2) AS avg_payment
    FROM transactions_with_age_group
    GROUP BY age_group, quarter_label
),

quarter_totals AS (
    SELECT
        quarter_label,
        COUNT(*) AS total_ops_in_quarter,
        SUM(Sum_payment) AS total_sum_in_quarter
    FROM transactions_with_age_group
    GROUP BY quarter_label
)

SELECT
    q.quarter_label,
    q.age_group,
    q.operations,
    q.total_sum,
    q.avg_payment,
    ROUND(q.operations / qt.total_ops_in_quarter * 100, 2) AS percent_ops_share,
    ROUND(q.total_sum / qt.total_sum_in_quarter * 100, 2) AS percent_sum_share
FROM quarterly_summary q
JOIN quarter_totals qt ON q.quarter_label = qt.quarter_label
ORDER BY q.quarter_label, q.age_group;

