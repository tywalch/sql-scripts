SELECT Count(*) as 'Num of Tickets', u.email as 'Admin'
FROM Tickets as t
JOIN Users as u
ON t.Assigned_To = u.id
WHERE (strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and (Category like 'Unspecified' or Category like 'null' or Category is null)
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
GROUP BY Assigned_To
