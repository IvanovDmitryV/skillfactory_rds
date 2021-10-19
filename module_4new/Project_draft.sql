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
select 
    amn.aircraft_code,
    amn.amount,
    max(amn.Economy_cnt)
from
    (select
        tf.flight_id,
        fl.aircraft_code,
        tf.amount,

        sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt,

        sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount
    from 
        dst_project.ticket_flights as tf
            join dst_project.flights as fl on tf.flight_id=fl.flight_id
    where 
        fl.departure_airport = 'AAQ' and
        tf.fare_conditions = 'Economy'
    group by 
        tf.flight_id,
        fl.aircraft_code,
        tf.amount) as amn
group by
    amn.aircraft_code,
    amn.amount
    
order by 
    amn.aircraft_code
/****/
select
    tf.flight_id,
    count (*) as all_pass_count,
    sum((tf.fare_conditions = 'Business')::int) as Business_cnt,
    sum((tf.fare_conditions = 'Economy')::int) as Economy_cnt,
    sum(tf.amount) as all_pass_amount,
    sum((tf.fare_conditions = 'Business')::int * tf.amount) as Business_amount,
    sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount,
--    case when fl.aircraft_code = '733' then (13400*6 + 12200*112 + )
--        else (6900*5 + 6300*80) as 
--        end,    
from 
    dst_project.ticket_flights as tf
        join dst_project.flights as fl on tf.flight_id=fl.flight_id
group by 
    tf.flight_id

/*select 
    CASE
    WHEN 2>1 THEN 2
    ELSE 1
END*/


