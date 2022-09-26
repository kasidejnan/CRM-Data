SELECT 
    *
FROM
    (SELECT 
        jobopen_id AS job_openid,
            CASE
                WHEN
                    extend_start_date IS NULL
                        OR start_date < extend_start_date
                THEN
                    DATE(start_date)
                ELSE DATE(extend_start_date)
            END AS start_date,
            CASE
                WHEN
                    extend_last_date IS NULL
                        OR last_date > extend_last_date
                THEN
                    DATE(last_date)
                ELSE DATE(extend_last_date)
            END AS last_date
    FROM
        (SELECT 
        MAX(id) AS id,
            jobopen_id,
            website,
            pending_date AS start_date,
            MAX(createdate) AS last_date
    FROM
        adwords.google_seasoning_pending
    WHERE
        createdate IN (SELECT 
                MAX(createdate)
            FROM
                adwords.google_seasoning_pending
            GROUP BY DATE(createdate))
            AND bpending = 1
    GROUP BY jobopen_id , pending_date) a
    LEFT JOIN (SELECT 
        MAX(id) AS extend_id,
            jobopen_id AS extend_jobopen_id,
            pending_date AS extend_start_date,
            MAX(createdate) AS extend_last_date
    FROM
        adwords.google_seasoning_pending
    WHERE
        createdate IN (SELECT 
                MAX(createdate)
            FROM
                adwords.google_seasoning_pending
            GROUP BY DATE(createdate))
            AND bpending = 1
    GROUP BY jobopen_id , pending_date) b ON a.jobopen_id = b.extend_jobopen_id
        AND DATE(a.last_date) >= DATE(b.extend_start_date - INTERVAL 1 DAY)
        AND a.last_date < b.extend_last_date
    ORDER BY start_date) a
GROUP BY job_openid , last_date