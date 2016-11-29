SELECT COUNT(t.id) as 'Total Tickets'
	,CASE t.assigned_to
		WHEN 54 THEN 'Bobby'
		WHEN 4 THEN 'Tyler'
	END as 'Assigned To'
	,t.Category as 'Category'
	,u.email
	,ROUND(ABS(AVG(julianday(t.created_at) - julianday(t.closed_at) -
		CASE
			WHEN julianday(t.created_at) = julianday(t.closed_at) THEN 0
			ELSE (CAST((julianday(t.created_at) - julianday(t.closed_at)) / 7 AS INTEGER) * 2) +
				CASE
					WHEN strftime('%w', t.closed_at) <= strftime('%w', t.created_at) THEN 2
					ELSE strftime('%w', t.closed_at) = '6'
				END
		END)),2) as 'ADTC'
FROM tickets as t
JOIN users as u
ON t.created_by = u.id
WHERE (strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
	and t.closed_at is not null
GROUP BY t.Category, u.email
ORDER BY ADTC