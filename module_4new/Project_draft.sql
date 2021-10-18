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