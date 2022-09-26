SELECT 
    *
FROM
    (SELECT 
        customerpending.JobOpen_ID AS job_openid,
            TRIM(customeradwords.website) AS name,
            TRIM(businesstype.BusinessType) AS business,
            CASE
				WHEN user.name REGEXP 'MCC[0-9][0-9]' THEN CONCAT('MCC', SUBSTR(name, 4, 2), ' ', user.nickname)
				WHEN user.name REGEXP 'MCC[0-9]' THEN CONCAT('MCC', LPAD(SUBSTRING(name, 4, 1), 2, 0), ' ', user.nickname)
				ELSE user.name
			END AS mcc_name,
            TRIM(customeradwords.GoogleCustomerID) AS cid,
            CASE
                WHEN (parent_date_pay1 IS NULL) THEN DATE(date_pay1)
                ELSE DATE(parent_date_pay1)
            END AS pay1_date,
            CASE
                WHEN product.brand != '' THEN product.brand
                ELSE last_renew.package
            END AS first_package,
            (service.pay1 + service.pay2)/1.07 AS first_price,
            CASE
                WHEN last_renew.package IS NOT NULL THEN last_renew.package
                ELSE product.brand
            END AS package,
            CASE
                WHEN last_renew.package IS NOT NULL THEN last_renew.Money/1.07
                ELSE (service.pay1 + service.pay2)/1.07
            END AS price,
            CASE
                WHEN last_renew.package IS NOT NULL THEN 0
                ELSE 1
            END AS is_new_customer,
            DATE(customerfollow.StartAds) AS startads_date,
            DATE(customeradwords.Current_ExpireDate) AS expire_date,
            customeradwords.bPending as bPending,
            case when service.parentjob_id != 0 then service.parentjob_id else service.id end as parentjob_openid
    FROM
        (SELECT 
        customeradwords.id,
            customeradwords.Website,
            customeradwords.OfficerConnect_ID,
            customeradwords.businesstype,
            customeradwords.Current_ExpireDate,
            case when customeradwords.bcancel = 1 then 2 when customeradwords.brefund = 1 then 2 else customeradwords.bPending end as bPending,
            account.GoogleCustomerID,
            customerhistory.JobOpen_ID
    FROM
        adwords.customeradwords
    JOIN adwords.account ON account.ID = customeradwords.Account_ID
    JOIN customerhistory ON customeradwords.ID = customerhistory.CustomerAW_ID
    ORDER BY Current_ExpireDate DESC) customeradwords
    LEFT JOIN itopplus_erp.user ON customeradwords.OfficerConnect_ID = user.adwords_officer_id
    JOIN adwords.customerfollow ON customeradwords.id = customerfollow.CustomerAW_ID
        AND customerfollow.bFollowStatus = 7
    JOIN (SELECT 
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
            GROUP BY JobOpen_ID)) customerpending ON customeradwords.JobOpen_ID = customerpending.JobOpen_ID
    JOIN theiconwebcrm.productlist ON customerpending.JobOpen_ID = productlist.id
    JOIN theiconwebcrm.product ON productlist.id_product = product.id_product
    JOIN theiconwebcrm.service ON service.id = productlist.id
    LEFT JOIN adwords.businesstype ON customeradwords.businesstype = businesstype.id
    LEFT JOIN (SELECT 
        id, date_pay1 AS parent_date_pay1
    FROM
        theiconwebcrm.service
    WHERE
        id != 0) d ON service.parentjob_id = d.id
    LEFT JOIN (SELECT 
        customerrenewhistory.CustomerAW_ID AS customer_aw_id,
            Package AS package,
            Money,
            customerrenewhistory.OldCurrentExp AS new_expire_date
    FROM
        adwords.customerrenewhistory
    JOIN (SELECT 
        CustomerAW_ID, MAX(PaymentDate) AS last_payment_date
    FROM
        adwords.customerrenewhistory
    WHERE
        PaymentStatus IN (1 , 2, 3)
            AND InvoiceReceipt IN (0 , 2)
    GROUP BY CustomerAW_ID) last_renew ON customerrenewhistory.CustomerAW_ID = last_renew.CustomerAW_ID
        AND customerrenewhistory.PaymentDate = last_renew.last_payment_date
    WHERE
        last_payment_date IS NOT NULL) last_renew ON customeradwords.ID = last_renew.customer_aw_id
    ORDER BY expire_date DESC) a
WHERE
		YEAR(expire_date) >= YEAR(CURDATE()) - 2
        and (mcc_name like "%MCC%" or mcc_name like "%MAC%")
--         and name not LIKE 'transfer%'
--         and name not LIKE 'refund%'
ORDER BY a.expire_date