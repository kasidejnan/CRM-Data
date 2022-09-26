SELECT 
    google_account_budget.cid,
    google_account_budget.date,
    google_account_budget.payment_setting,
    google_account_budget.daily_budget,
    google_account_budget.remaining_budget,
    IFNULL(google_account_performance.impression, 0) AS impression,
    IFNULL(google_account_performance.click, 0) AS click,
    IFNULL(google_account_performance.conversion, 0) AS conversion,
    IFNULL(google_account_performance.cost, 0) AS cost,
    google_account_manager_cid.name as account_manager_name
FROM
    itopplusdb.google_account_budget
        LEFT JOIN
    itopplusdb.google_account_performance ON google_account_budget.cid = google_account_performance.cid
        AND google_account_budget.date = google_account_performance.date
        left join
        itopplusdb.google_account_manager_cid on google_account_budget.account_manager_id = google_account_manager_cid.cid
WHERE
    YEAR(google_account_budget.date) >= YEAR(CURDATE()) - 1
--     and month(google_account_budget.date) >= 7
ORDER BY date DESC