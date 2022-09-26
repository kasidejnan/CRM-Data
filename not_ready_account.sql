SELECT DISTINCT
    a.JobOpen_ID AS job_openid,
    a.website AS name,
    a.brand AS package,
    first_price,
    CASE
        WHEN (parent_date_pay1 IS NULL) THEN date(date_pay1)
        ELSE date(parent_date_pay1)
    END AS pay1_date,
    CASE
        WHEN (parent_date_pay1 IS NULL) THEN YEAR(date_pay1)
        ELSE YEAR(parent_date_pay1)
    END AS pay1_year,
    CASE
        WHEN (parent_date_pay1 IS NULL) THEN MONTH(date_pay1)
        ELSE MONTH(parent_date_pay1)
    END AS pay1_month,
    CASE WHEN (a.website LIKE 'transfer%'
            or a.website LIKE 'refund%') THEN 'CANCEL_BY_CUSTOMER'
            else a.NOT_READY_STATUS end AS status,
    '-' as assignee,
    case when a.parentjob_id != 0 then a.parentjob_id else a.JobOpen_ID end as parentjob_openid
FROM
    (SELECT 
        service.date_pay1,
            service.website,
            product.brand,
            customerpending.JobOpen_ID,
            customerpending.NOT_READY_STATUS,
            service.parentjob_id,
            service.pay1 + service.pay2 AS first_price
    FROM
        (SELECT 
        *
    FROM
        adwords.customerpending
    WHERE
        customerpending.id IN (SELECT 
                MAX(id)
            FROM
                adwords.customerpending
            GROUP BY JobOpen_ID)) customerpending
    JOIN theiconwebcrm.productlist ON customerpending.JobOpen_ID = productlist.id
    JOIN theiconwebcrm.product ON productlist.id_product = product.id_product
    JOIN theiconwebcrm.service ON service.id = customerpending.JobOpen_ID
    WHERE
        product.team_owner = 'GOOGLE'
            AND customerpending.bnot_ready = 1
            AND NOT_READY_STATUS IS NOT NULL
            AND service.status1 = 1
            AND service.website not LIKE 'transfer%'
            AND service.website not LIKE 'refund%'
            AND YEAR(service.date_pay1) >= YEAR(CURDATE()) - 2) a
        LEFT JOIN
    (SELECT 
        id, date_pay1 AS parent_date_pay1
    FROM
        theiconwebcrm.service
    WHERE
        id != 0) b ON a.parentjob_id = b.id
ORDER BY pay1_year, pay1_month