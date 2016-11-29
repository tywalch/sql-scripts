SELECT COUNT(*) as 'Total Tickets'
	,CASE assigned_to
		WHEN 54 THEN 'Bobby'
		WHEN 4 THEN 'Tyler'
	END as 'Assigned To'
	,Category as 'Category'
	,ROUND(ABS(AVG(julianday(created_at) - julianday(closed_at) -
		CASE 
			WHEN julianday(created_at) = julianday(closed_at) THEN 0
			ELSE (CAST((julianday(created_at) - julianday(closed_at)) / 7 AS INTEGER) * 2) +
				CASE 
					WHEN strftime('%w', closed_at) <= strftime('%w', created_at) THEN 2
					ELSE strftime('%w', closed_at) = '6'
				END
			END)),2) as 'ADTC'
FROM tickets as t
WHERE (strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
	and t.closed_at is not null
GROUP BY Category, Assigned_To
ORDER BY ADTC