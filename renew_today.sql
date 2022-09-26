SELECT 
    customerhistory.JobOpen_ID AS job_openid,
    customerrenewhistory.package AS package,
    customerrenewhistory.OldCurrentExp AS expire_date,
    customerrenewhistory.PaymentDate AS timestamp,
    customerrenewhistory.money/1.07 AS price
FROM
    adwords.customerrenewhistory
        JOIN
    customerhistory ON customerrenewhistory.CustomerAW_ID = customerhistory.CustomerAW_ID
WHERE
    PaymentStatus IN (1 , 2, 3)
        AND InvoiceReceipt IN (0 , 2)
        and year(PaymentDate) = year(curdate())
        and month(PaymentDate) = month(curdate())
order by customerrenewhistory.PaymentDate