SELECT 
    job_openid,
    package,
    DATE(expire_date) AS expire_date,
    DATE(payment_date) AS payment_date,
    remarks,
    price/1.07 as price
FROM
    (SELECT 
        customerhistory.jobopen_id AS job_openid,
            customerrenewhistory.package AS package,
            customerrenewhistory.OldCurrentExp AS expire_date,
            customerrenewhistory.PaymentDate AS payment_date,
            'renew on expire month' AS remarks,
            customerrenewhistory.money AS price
    FROM
        adwords.customerrenewhistory
    JOIN customerhistory ON customerrenewhistory.CustomerAW_ID = customerhistory.CustomerAW_ID
    WHERE
        PaymentStatus IN (1 , 2, 3)
            AND InvoiceReceipt IN (0 , 2)
            AND YEAR(customerrenewhistory.OldCurrentExp) >= YEAR(CURDATE()) - 2
            AND MONTH(customerrenewhistory.OldCurrentExp) = MONTH(customerrenewhistory.PaymentDate)
            AND YEAR(customerrenewhistory.OldCurrentExp) = YEAR(customerrenewhistory.PaymentDate) UNION SELECT 
        customerhistory.jobOpen_id,
            customerrenewhistory.package,
            customerrenewhistory.OldCurrentExp,
            customerrenewhistory.PaymentDate,
            'renew before expire month' AS remarks,
            customerrenewhistory.money AS price
    FROM
        adwords.customerrenewhistory
    JOIN customerhistory ON customerrenewhistory.CustomerAW_ID = customerhistory.CustomerAW_ID
    WHERE
        PaymentStatus IN (1 , 2, 3)
            AND InvoiceReceipt IN (0 , 2)
            AND YEAR(customerrenewhistory.OldCurrentExp) >= YEAR(CURDATE()) - 2
            AND customerrenewhistory.OldCurrentExp > customerrenewhistory.PaymentDate
            AND (MONTH(customerrenewhistory.OldCurrentExp) != MONTH(customerrenewhistory.PaymentDate)
            OR YEAR(customerrenewhistory.OldCurrentExp) != YEAR(customerrenewhistory.PaymentDate)) UNION (SELECT 
        customerhistory.jobOpen_id,
            customerrenewhistory.package,
            customerrenewhistory.OldCurrentExp,
            customerrenewhistory.PaymentDate,
            'renew backward' AS remarks,
            customerrenewhistory.money AS price
    FROM
        adwords.customerrenewhistory
    JOIN customerhistory ON customerrenewhistory.CustomerAW_ID = customerhistory.CustomerAW_ID
    WHERE
        PaymentStatus IN (1 , 2, 3)
            AND InvoiceReceipt IN (0 , 2)
            AND YEAR(customerrenewhistory.OldCurrentExp) >= YEAR(CURDATE()) - 2
            AND customerrenewhistory.OldCurrentExp < customerrenewhistory.PaymentDate
            AND (MONTH(customerrenewhistory.OldCurrentExp) != MONTH(customerrenewhistory.PaymentDate)
            OR YEAR(customerrenewhistory.OldCurrentExp) != YEAR(customerrenewhistory.PaymentDate)))) a
        JOIN
    customerhistory ON customerhistory.JobOpen_ID = a.job_openid
        JOIN
    customeradwords ON customeradwords.id = customerhistory.CustomerAW_ID
        LEFT JOIN
    itopplus_erp.user ON customeradwords.OfficerConnect_ID = user.adwords_officer_id
WHERE
    (user.name LIKE '%MCC%'
        OR user.name LIKE '%MAC%')