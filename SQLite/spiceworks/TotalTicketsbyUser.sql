Select COUNT(t.id) as 'Total Tickets', u.email as 'User'
FROM Users as u
INNER JOIN Tickets as t
	on u.id = t.created_by
WHERE (strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
GROUP BY u.email
ORDER BY COUNT(t.id) desc 
