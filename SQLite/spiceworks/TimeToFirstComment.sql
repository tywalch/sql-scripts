SELECT t.id, t.Category, u.email
	,CASE t.assigned_to
		WHEN 54 THEN 'Bobby'
		WHEN 4 THEN 'Tyler'
	END as 'Assigned To'
   	,(strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60 as 'Minutes to First Comment'
  	,CASE 
   		WHEN ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60) < 60 THEN ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60) ||  ' Minutes'
   		WHEN ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60) >= 60 AND ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60) < 1440 THEN ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60 / 60)  || ' Hours'
   		WHEN ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60) >= 1440  THEN '>' || ((strftime('%s',MIN(c.Created_At)) - strftime('%s',t.created_at)) / 60 / 60 / 24)  || ' Days'
	END as 'Time to First Comment'
FROM tickets as t
LEFT JOIN comments as c
ON t.id = c.ticket_id
LEFT JOIN users as u
ON t.created_by = u.id
WHERE 
	(strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and c.body not like 'Attachment:%'
	and c.body not like 'Assigned_to%'
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
GROUP BY t.id, t.assigned_to, t.Category
