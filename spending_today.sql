SELECT 
    customerhistory.JobOpen_ID AS job_openid,
    google_account_performance.cost AS mtd_spending
FROM
    (SELECT 
        google_account_performance.cid,
            SUM(google_account_performance.cost) AS cost
    FROM
        itopplusdb.google_account_performance
    JOIN itopplusdb.google_account_budget ON google_account_budget.date = google_account_performance.date
        AND google_account_budget.cid = google_account_performance.cid
    WHERE
        YEAR(google_account_performance.date) = YEAR(CURDATE())
            AND MONTH(google_account_performance.date) = MONTH(CURDATE())
            and google_account_budget.payment_setting = 'Monthly Invoicing'
    GROUP BY google_account_performance.cid) google_account_performance
        JOIN
    adwords.account ON google_account_performance.cid = account.GoogleCustomerID COLLATE utf8_unicode_ci
        JOIN
    adwords.customeradwords ON account.id = customeradwords.Account_ID
        JOIN
    adwords.customerhistory ON customerhistory.CustomerAW_ID = customeradwords.id
    where (year(customeradwords.Current_ExpireDate) = year(curdate()) and month(customeradwords.Current_ExpireDate) = month(curdate())) or customeradwords.Current_ExpireDate > curdate()