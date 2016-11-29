SELECT
	Id
	,summary
	,email
	,CommentBody as 'Last Comment'
	,CommentorEmail as 'Comment By'
	,MAX(CommentCreated) as 'Comment Date'
	,CASE
		WHEN Closed_At is null and Commentor = 'Bobby' THEN 'Requires User Action'
		WHEN Closed_At is null and Commentor = 'User' THEN 'Requires IT Action'
		WHEN Closed_at is not null THEN 'Closed'
	END as 'Status'
	,CASE
		WHEN Closed_at is not null THEN ROUND((julianday(closed_at) - julianday(commentcreated)),2)
		WHEN Closed_at is null THEN ROUND((julianday('now') - julianday(commentcreated)),2)
	END as 'Comment Time (Days)'
FROM (
SELECT
	t.id
	,t.summary
	,u.email
	,t.created_at
	,t.closed_at
	,MAX(c.created_at) as 'CommentCreated'
	,'Bobby' as 'Commentor'
	,c.body as 'CommentBody'
	,uc.email as 'CommentorEmail'
FROM Tickets as t
LEFT JOIN Comments as c
ON t.id = c.ticket_id
LEFT JOIN users as u
ON t.created_by = u.id
LEFT JOIN users as uc
ON c.created_by = uc.id
WHERE 
	(strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and c.body not like 'Attachment:%'
	and c.body not like 'Assigned_to%'
	and c.body not like 'Ticket closed%'
	and c.body not like '%total time spent on this ticket%'
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
	and (c.created_by = 54 or c.created_by = 4)
GROUP BY t.id
UNION ALL
SELECT
	t.id
	,t.summary
	,u.email
	,t.created_at
	,t.closed_at
	,MAX(c.created_at) as 'CommentCreated'
	,'User' as 'Commentor'
	,c.body as 'CommentBody'
	,uc.email as 'CommentorEmail'
FROM Tickets as t
LEFT JOIN Comments as c
ON t.id = c.ticket_id
LEFT JOIN users as u
ON t.created_by = u.id
LEFT JOIN users as uc
ON c.created_by = uc.id
WHERE 
	(strftime('%m', t.created_at) = strftime('%m', DATE('now','-2 month'))
	or strftime('%m', t.created_at) = strftime('%m', DATE('now','-1 month'))
	or strftime('%m', t.created_at) = strftime('%m', 'now')) 
	and strftime('%Y', t.created_at) = strftime('%Y', 'now') 
	and c.body not like 'Attachment:%'
	and c.body not like 'Assigned_to%'
	and c.body not like 'Ticket closed%'
	and c.body not like '%total time spent on this ticket%'
	and t.category not like 'Ignore'
	and LENGTH(t.c_initiative) = 0
	and t.c_internal_it_category = 'Normal'
	and (c.created_by <> 54 or c.created_by <> 4)
GROUP BY t.id
)
GROUP BY id
HAVING Status <> 'Closed'
ORDER BY Status