SELECT 
    service.id AS parentjob_openid,
    service.website AS name,
    product.brand AS package,
    (service_period.period1 + service_period.period2 + service_period.period3 + service_period.period4 + service_period.period5 + service_period.period6)/1.07 as price_exvat,
    DATE(date_pay1) AS pay1_date,
    employee.name_emp AS salesperson_name
FROM
    theiconwebcrm.approveclosejob
        JOIN
    theiconwebcrm.employee ON approveclosejob.ID_Employee = employee.ID_Employee
        JOIN
    theiconwebcrm.employee employee_manager ON employee_manager.id_employee = employee.leader
        JOIN
    theiconwebcrm.service ON service.id = approveclosejob.ID_JobOpen
        JOIN
    theiconwebcrm.service_period ON service.id = service_period.id_jobopen
        JOIN
    theiconwebcrm.product ON service_period.id_product = product.id_product
WHERE
    YEAR(service.date_pay1) >= YEAR(CURDATE()) -1
    and service.status1 = 1
        AND employee_manager.id_employee = 123123577
        AND (NOT service_period.additionalname LIKE '%เติมเงิน%')