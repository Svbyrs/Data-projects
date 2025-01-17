#3 TASK

CREATE DATABASE test_db;
SELECT * FROM audio_cards;
SELECT * FROM audiobooks;
SELECT * FROM listenings;

#1 Question (Выведите сколько пользователей добавили книгу 'Coraline', сколько пользователей прослушало больше 10%)
SELECT COUNT(DISTINCT l.user_id) AS Count
FROM listenings l
JOIN audiobooks a ON a.uuid = l.audiobook_uuid
WHERE title = 'Coraline'
UNION ALL
SELECT COUNT(DISTINCT l.user_id) AS Count
FROM listenings l
JOIN audio_cards ac ON ac.audiobook_uuid = l.audiobook_uuid
JOIN audiobooks a ON a.uuid = l.audiobook_uuid
WHERE title = 'Coraline' AND progress > (0.10 * duration);

#2 Question (По каждой операционной системе и названию книги выведите количество пользователей, сумму прослушивания в часах, не учитывая тестовые прослушивания)
SELECT l.os_name, a.title, COUNT(DISTINCT l.user_id) AS Count, SUM(ac.progress)/3600 AS total_hour
FROM listenings l
JOIN audio_cards ac ON ac.audiobook_uuid = l.audiobook_uuid
JOIN audiobooks a ON a.uuid = l.audiobook_uuid
WHERE l.is_test = '0'
GROUP BY l.os_name, a.title;

#3 Question (Найдите книгу, которую слушает больше всего людей)
SELECT a.title, COUNT(DISTINCT l.user_id) AS Count
FROM listenings l 
JOIN audiobooks a ON a.uuid = l.audiobook_uuid
GROUP BY a.title
ORDER BY Count DESC;

#4 Qusetion (Найдите книгу, которую чаще всего дослушивают до конца)
SELECT a.title, COUNT(DISTINCT ac.user_id) AS Count
FROM audiobooks a
JOIN audio_cards ac ON ac.audiobook_uuid = a.uuid
WHERE a.duration = ac.progress
GROUP BY a.title
ORDER BY Count DESC;