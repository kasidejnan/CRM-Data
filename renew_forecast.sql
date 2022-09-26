SELECT 
    job_openid,
    CASE
        WHEN forecast_status IS NULL THEN ''
        ELSE forecast_status
    END as forecast_status,
    CASE
        WHEN reason IS NULL THEN ''
        WHEN trim(reason) = 'NULL' THEN ''
        ELSE trim(reason)
    END as remarks
FROM
    (SELECT 
        JobOpen_ID AS job_openid, forecast_status, reason
    FROM
        itopplus_erp.google_forecast_renew
    JOIN adwords.customerhistory ON google_forecast_renew.CustomerAW_ID = customerhistory.CustomerAW_ID
    WHERE
        YEAR(expiredate) >= YEAR(CURDATE())-1
    ORDER BY expiredate DESC) a
GROUP BY job_openid