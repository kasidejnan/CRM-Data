SELECT 
    job_openid,
    name,
    package,
    first_price,
    pay1_date,
    year(pay1_date) as pay1_year,
    month(pay1_date) as pay1_month,
    case
		when assignee is null then 'NOT_DISTRIBUTED'
        else 'DISTRIBUTED_BUT_NOT_OPEN'
	end as status,
    case
		when assignee is null then '-'
        else assignee
        end as assignee,
        parentjob_openid,current_status,distribute_date,last_update
FROM
    (SELECT DISTINCT
        c.JobOpen_ID AS job_openid,
            c.website AS name,
            c.brand AS package,
            first_price,
            CASE
                WHEN (parent_date_pay1 IS NULL) THEN DATE(date_pay1)
                ELSE DATE(parent_date_pay1)
            END AS pay1_date,
            CASE
                WHEN c.bFollowStatus = 7 THEN 1
                ELSE 0
            END AS is_open,
            mcc_name AS assignee,
            DATE(startads_date) AS startads_date,
            case when c.parentjob_id != 0 then c.parentjob_id else c.JobOpen_ID end as parentjob_openid,
            google_process_flow.current_status,
            c.distribute_date,
            google_process_flow.last_update
    FROM
        (SELECT 
        service.date_pay1,
            service.website,
            product.brand,
            customerfollow.bFollowStatus,
            customerpending.JobOpen_ID,
            service.parentjob_id,
            CASE
                WHEN customerfollow.startads IS NULL THEN customerfollow.createdate
                ELSE customerfollow.startads
            END AS startads_date,
            customerfollow.mcc_name,
            service.pay1 + service.pay2 AS first_price,
            customerfollow.distribute_date
    FROM
        (SELECT 
        JobOpen_ID, bnot_ready
    FROM
        adwords.customerpending
    WHERE
        customerpending.id IN (SELECT 
                MAX(id)
            FROM
                adwords.customerpending
            WHERE
                customerpending.bnot_ready = 0
            GROUP BY JobOpen_ID)) customerpending
    JOIN theiconwebcrm.productlist ON customerpending.JobOpen_ID = productlist.id
    JOIN theiconwebcrm.product ON productlist.id_product = product.id_product
    JOIN theiconwebcrm.service ON service.id = customerpending.JobOpen_ID
    LEFT JOIN (SELECT 
        customerhistory.JobOpen_ID,
            customerfollow.startads,
            customerfollow.CreateDate,
            CASE
				WHEN user.name REGEXP 'MCC[0-9][0-9]' THEN CONCAT('MCC', SUBSTR(name, 4, 2), ' ', user.nickname)
				WHEN user.name REGEXP 'MCC[0-9]' THEN CONCAT('MCC', LPAD(SUBSTRING(name, 4, 1), 2, 0), ' ', user.nickname)
				ELSE user.name
			END as mcc_name,
            customerfollow.bFollowStatus,
            date(customeradwords.createdate) as distribute_date
    FROM
        adwords.customerhistory
    LEFT JOIN adwords.customerfollow ON customerhistory.CustomerAW_ID = customerfollow.CustomerAW_ID
    LEFT JOIN adwords.customeradwords ON customerhistory.CustomerAW_ID = customeradwords.id
    LEFT JOIN itopplus_erp.user ON customeradwords.OfficerConnect_ID = user.adwords_officer_id) customerfollow ON customerpending.JobOpen_ID = customerfollow.JobOpen_ID
    WHERE
        product.team_owner = 'GOOGLE'
            AND service.status1 = 1
            AND service.website NOT LIKE 'transfer%'
            AND service.website NOT LIKE 'refund%'
            AND NOT (customerfollow.JobOpen_ID IS NOT NULL
            AND customerfollow.bFollowStatus IS NULL)) c
    LEFT JOIN (SELECT 
        id, date_pay1 AS parent_date_pay1
    FROM
        theiconwebcrm.service
    WHERE
        id != 0) d ON c.parentjob_id = d.id
         left join (SELECT 
    *
FROM
    (SELECT 
        customerhistory.JobOpen_ID as job_openid,
            google_process_flow.current_status,
            date(customeradwords.CreateDate) as distribute_date,
            date(google_process_flow.lastupdate) as last_update
    FROM
        itopplus_erp.google_process_flow
    JOIN adwords.customerhistory ON google_process_flow.CustomerAW_ID = customerhistory.CustomerAW_ID
    join adwords.customeradwords on customeradwords.id = google_process_flow.CustomerAW_ID
    ORDER BY lastupdate DESC) a group by job_openid) google_process_flow on c.JobOpen_ID = google_process_flow.job_openid
        ) a
WHERE
    a.is_open = 0 and year(pay1_date) >= year(curdate()) - 2
ORDER BY pay1_date