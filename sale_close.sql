SELECT 
    service.id AS parentjob_openid,
    service.website AS name,
    product.brand AS package,
    (service_period.period1 + service_period.period2 + service_period.period3 + service_period.period4 + service_period.period5 + service_period.period6)/1.07 as price_exvat,
    DATE(date_pay1) AS pay1_date,
    case
		when employee.nickname is not null then employee.nickname
        else employee.name_emp
	end as staff,
    case
		when employee_manager.nickname is not null then employee_manager.nickname
        else employee_manager.name_emp
	end as staff_manager,
    jopopen.bBookinglist,
    service.status1,
    date(jopopen.booking_date) as booking_date
FROM
    theiconwebcrm.approveclosejob
        JOIN
    theiconwebcrm.employee ON approveclosejob.ID_Employee = employee.ID_Employee
        JOIN
    (select employee.id_employee, employee_manager.name_emp, employee_manager.nickname from
    theiconwebcrm.employee
		JOIN
    theiconwebcrm.employee employee_manager ON employee_manager.id_employee = employee.leader) employee_manager ON employee_manager.id_employee = employee.leader
        JOIN
    theiconwebcrm.service ON service.id = approveclosejob.ID_JobOpen
        JOIN
    theiconwebcrm.service_period ON service.id = service_period.id_jobopen
        JOIN
    theiconwebcrm.product ON service_period.id_product = product.id_product
		left join
	theiconwebcrm.jopopen on jopopen.id = service.id
WHERE
    YEAR(service.date_pay1) >= YEAR(CURDATE()) - 1
    and (service.status1 = 1 or bBookinglist = 1)
        AND (NOT service_period.additionalname LIKE '%เติมเงิน%')
        order by service.id desc