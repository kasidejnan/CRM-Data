SELECT 
    customerhistory.JobOpen_ID AS job_openid,
    customeraddfundhistory.AddFund/1.07 AS price,
    customeraddfundhistory.LastUpdate AS timestamp
FROM
    adwords.customeraddfundhistory
        JOIN
    customerhistory ON customerhistory.CustomerAW_ID = customeraddfundhistory.CustomerAWID
WHERE
    PaymentStatus IN (1 , 2, 3)
        AND InvoiceReceipt IN (0 , 2)
        AND YEAR(customeraddfundhistory.LastUpdate) = YEAR(CURDATE())
        AND month(customeraddfundhistory.LastUpdate) = month(CURDATE())
ORDER BY customeraddfundhistory.LastUpdate