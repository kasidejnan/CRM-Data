SELECT 
        *
    FROM
        (SELECT 
        google_account_budget.cid, google_account_manager_cid.name as account_manager
    FROM
        itopplusdb.google_account_budget
    LEFT JOIN itopplusdb.google_account_manager_cid ON google_account_budget.account_manager_id = google_account_manager_cid.cid
    WHERE
        google_account_manager_cid.name LIKE '%SubMcc%'
            OR google_account_manager_cid.name LIKE '%SubADG%'
    ORDER BY date DESC) a
    GROUP BY cid