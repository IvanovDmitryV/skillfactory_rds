/*Boeing 737-300:  2,4 тыс. кг/ч;
Sukhoi Superjet 100:  1,7 тыс. кг/ч;*/

select 
    *
from 
    dst_project.flights as fl
where 
    fl.departure_airport = 'AAQ' and 
    (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
    fl.status not in ('Cancelled') 
order by 
    fl.scheduled_departure
	
/************************************************************/
select
    tf.flight_id,
    count (*) as all_pass_count,
    sum((tf.fare_conditions = 'Business')::int) as Business_cnt,
    sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt,
    sum(tf.amount) as all_pass_amount,
    sum((tf.fare_conditions = 'Business')::int * tf.amount) as Business_amount,
    sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount
from 
    dst_project.ticket_flights as tf
group by 
    tf.flight_id
/**************************************************************************************************/
select 
    flt.flight_id,
    count(*) as aircraft_capacity,
    sum((st.fare_conditions = 'Business')::int) as Business_class,
    sum((st.fare_conditions = 'Economy')::int) as Economy_class
from    
    (
    select 
        row_number() over (order by ararr.city,fl.scheduled_departure),
        fl.flight_id,
        ardep.city as departure_from,
        ararr.city as arrival_to,
        fl.aircraft_code,
        fl.actual_departure,
        fl.actual_arrival,
        extract(epoch from(fl.actual_arrival - fl.actual_departure))/60 as duration, 
        extract(epoch from
            (lead(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure) - fl.scheduled_departure))/3600 as to_next_flight ,
        extract(epoch from
            (fl.scheduled_departure - lag(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure)))/3600 as after_prev_flight
    
    from 
        dst_project.flights as fl
            join dst_project.airports as ardep on fl.departure_airport = ardep.airport_code
                join dst_project.airports as ararr on fl.arrival_airport = ararr.airport_code
    where 
        fl.departure_airport = 'AAQ' and 
        (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
        fl.status not in ('Cancelled')
    ) as flt
        join dst_project.seats as st on flt.aircraft_code = st.aircraft_code
group by 
        flt.flight_id     
        
        
/**************************************************************************************************/
select 
    *
from    
    (
    select 
    row_number() over (order by ararr.city,fl.scheduled_departure),
    fl.flight_id,
    ardep.city as departure_from,
    ararr.city as arrival_to,
    fl.aircraft_code,
    fl.actual_departure,
    fl.actual_arrival,
    extract(epoch from(fl.actual_arrival - fl.actual_departure))/60 as duration, 
    extract(epoch from
        (lead(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure) - fl.scheduled_departure))/3600 as to_next_flight ,
    extract(epoch from
        (fl.scheduled_departure - lag(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure)))/3600 as after_prev_flight
    
    from 
        dst_project.flights as fl
            join dst_project.airports as ardep on fl.departure_airport = ardep.airport_code
                join dst_project.airports as ararr on fl.arrival_airport = ararr.airport_code
    where 
        fl.departure_airport = 'AAQ' and 
        (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
        fl.status not in ('Cancelled')
    ) as flt
        join dst_project.seats as st on flt.aircraft_code = st.aircraft_code
    
    
    

/*id рейса и города вылета (Анапа) и прилета
**********************************************************************************
select 
--    row_number() over (order by ararr.city,fl.scheduled_departure),
    fl.flight_id,
    ardep.city as departure_from,
    ararr.city as arrival_to,
    fl.actual_departure,
    fl.actual_arrival,
    extract(epoch from
        (lead(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure) - fl.scheduled_departure))/3600 as to_next_flight ,
    extract(epoch from
        (fl.scheduled_departure - lag(fl.scheduled_departure) over (partition by ararr.city order by fl.scheduled_departure)))/3600 as after_prev_flight
    
from 
    dst_project.flights as fl
        join dst_project.airports as ardep on fl.departure_airport = ardep.airport_code
            join dst_project.airports as ararr on fl.arrival_airport = ararr.airport_code
where 
    fl.departure_airport = 'AAQ' and 
    (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
    fl.status not in ('Cancelled')

/*
**********************************************************************************
select 
    row_number() over (order by fl.scheduled_departure),
    aircraft_code,
    arrival_airport,
    flight_id,
    flight_no,
    scheduled_arrival,
    scheduled_departure,
    status
from 
    dst_project.flights as fl
where 
    fl.departure_airport = 'AAQ' and 
    (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
    fl.status not in ('Cancelled') 
order by 
    fl.scheduled_departure*/
/*****************************foel consumption table ******************************************/	
select *
from
	(select
		'733' as aircraft_code,
		2400 as consumption
	union all 
	select
		'SU9' as aircraft_code,
		1700 as consumption)
    as fuel_consmpt	
/************************************* flight tsble **************************************/
select *
from    
    (
    select 
    row_number() over (order by arr.city,fl.scheduled_departure),
    fl.flight_id,
    dep.city as departure_from,
    arr.city as arrival_to,
    fl.aircraft_code,
    fl.scheduled_departure,
    fl.scheduled_arrival,
    fl.actual_departure,
    fl.actual_arrival
    from 
        dst_project.flights as fl
            join dst_project.airports as dep on fl.departure_airport = dep.airport_code
                join dst_project.airports as arr on fl.arrival_airport = arr.airport_code
    where 
        fl.departure_airport = 'AAQ' and 
        (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
        fl.status not in ('Cancelled')
    ) as flt
/*********************************** capacity&amount table ***********************************/
(select 
    amn_economy.aircraft_code,
    amn_economy.amount,
    max(amn_economy.Economy_cnt)
from
    (select
        tf.flight_id,
        fl.aircraft_code,
        tf.amount,
        sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt
    from 
        dst_project.ticket_flights as tf
            join dst_project.flights as fl on tf.flight_id=fl.flight_id
    where 
        fl.departure_airport = 'AAQ' and
        tf.fare_conditions = 'Economy'
    group by 
        tf.flight_id,
        fl.aircraft_code,
        tf.amount) as amn_economy
group by
    amn_economy.aircraft_code,
    amn_economy.amount)
union all 
(select 
    amn_business.aircraft_code,
    amn_business.amount,
    max(amn_business.Business_cnt)
from
    (select
        tf.flight_id,
        fl.aircraft_code,
        tf.amount,
        sum((tf.fare_conditions = 'Business')::int) as Business_cnt
    from 
        dst_project.ticket_flights as tf
            join dst_project.flights as fl on tf.flight_id=fl.flight_id
    where 
        fl.departure_airport = 'AAQ' and
        tf.fare_conditions = 'Business'
    group by 
        tf.flight_id,
        fl.aircraft_code,
        tf.amount) as amn_business
group by    
    amn_business.aircraft_code,
    amn_business.amount)
order by 1
/************************************* all amounts table ************************************************************/
select
    tf.flight_id,
    count (*) as all_pass_count,
    sum((tf.fare_conditions = 'Business')::int) as Business_cnt,
    sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt,
    sum(tf.amount) as all_pass_amount,
    sum((tf.fare_conditions = 'Business')::int * tf.amount) as Business_amount,
    sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount,
    case when fl.aircraft_code = '733' then (13400*6 + 12200*112 + 36600*12)
        else (6900*5 + 6300*80 + 18900*12)  
        end
            as potential_amount
from 
    dst_project.ticket_flights as tf
        join dst_project.flights as fl on tf.flight_id=fl.flight_id
where 
    fl.departure_airport = 'AAQ'
group by 
    tf.flight_id,
    potential_amount
/********************************************interval from booking*****************************************************/
select 
    tf.flight_id,
    (fl.scheduled_departure - bk.book_date)::interval
from
    dst_project.flights as fl
        join dst_project.ticket_flights as tf on fl.flight_id=tf.flight_id
            join  dst_project.tickets as tc on tf.ticket_no=tc.ticket_no
                join dst_project.bookings as bk on tc.book_ref=bk.book_ref
order by 1
/**/
select 
    fl.flight_id,
    json_agg((fl.scheduled_departure - bk.book_date)::interval)
from
    dst_project.flights as fl
        join dst_project.ticket_flights as tf on fl.flight_id=tf.flight_id
            join  dst_project.tickets as tc on tf.ticket_no=tc.ticket_no
                join dst_project.bookings as bk on tc.book_ref=bk.book_ref
/*********************************************************************************************************************/
/************************************************PROJECT**************************************************************/
/*********************************************************************************************************************/
with 
    fuel_consmpt as 
    (select
        '733' as aircraft_code,
        2400 as consumption
    union all 
    select
        'SU9' as aircraft_code,
        1700 as consumption
    )
,
    flight_info as
    (
    select 
        row_number() over (order by arr.city,fl.scheduled_departure),
        fl.flight_id,
        dep.city as departure_from,
        arr.city as arrival_to,
        fl.aircraft_code,
        fl.scheduled_departure,
        fl.scheduled_arrival,
        fl.actual_departure,
        fl.actual_arrival
    from 
        dst_project.flights as fl
            join dst_project.airports as dep on fl.departure_airport = dep.airport_code
                join dst_project.airports as arr on fl.arrival_airport = arr.airport_code
    where 
        fl.departure_airport = 'AAQ' and 
        (date_trunc('month', fl.scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01')) and 
        fl.status not in ('Cancelled')
    )
,
    amount as
    (
    select
        tf.flight_id,
        count (*) as all_pass_count,
        sum((tf.fare_conditions = 'Business')::int) as Business_cnt,
        sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt,
        sum(tf.amount) as all_pass_amount,
        sum((tf.fare_conditions = 'Business')::int * tf.amount) as Business_amount,
        sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount,
        case when fl.aircraft_code = '733' then (13400*6 + 12200*112 + 36600*12)
            else (6900*5 + 6300*80 + 18900*12)  
            end
                as potential_amount
    from 
        dst_project.ticket_flights as tf
            join dst_project.flights as fl on tf.flight_id=fl.flight_id
    where 
        fl.departure_airport = 'AAQ'
    group by 
        tf.flight_id,
        potential_amount
    )
    
    select * 
    from flight_info as fi 
        join fuel_consmpt as fc on fi.aircraft_code=fc.aircraft_code
            join amount as am on fi.flight_id=am.flight_id
order by 1
