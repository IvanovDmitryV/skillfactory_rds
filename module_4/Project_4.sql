/*	Задание 4.1
База данных содержит список аэропортов практически всех крупных городов России. 
В большинстве городов есть только один аэропорт. Исключение составляет:*/
select 
    ap.city
from 
    dst_project.airports as ap
group by 
    ap.city
having
    count(*) > 1

/*Задание 4.2
Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах. Сколько всего статусов для рейсов определено в таблице?*/
select 
    count(distinct fl.status)
from 
    dst_project.flights as fl
 
/*Вопрос 2. Какое количество самолетов находятся в воздухе на момент среза в базе (статус рейса «самолёт уже вылетел и находится в воздухе»).*/
select 
    count(*)
from 
     dst_project.flights as fl
where 
    fl.status = 'Departed'
 
/*Вопрос 3. Места определяют схему салона каждой модели. Сколько мест имеет самолет модели  773 (Boeing 777-300)?*/
select 
    count(*)
from 
    dst_project.seats as st
where 
    st.aircraft_code = '773'
 
/*Вопрос 4. Сколько состоявшихся (фактических) рейсов было совершено между 1 апреля 2017 года и 1 сентября 2017 года?
Здесь и далее состоявшийся рейс означает, что он не отменён, и самолёт прибыл в пункт назначения.*/
select 
    count(*)
from 
    dst_project.flights as fl
where
    fl.actual_arrival > '2017-04-01' and 
    fl.actual_arrival < '2017-09-01' and
    fl.status = 'Arrived'
	
/*Задание 4.3
Вопрос 1. Сколько всего рейсов было отменено по данным базы?*/
select 
    count(*)
from 
    dst_project.flights as fl 
where 
    fl.status = 'Cancelled'

/*Вопрос 2. Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?*/
/*Boeing:*/
select 
    'Boeing ' as make,
    count(distinct ar.model) as model_count
from 
    dst_project.aircrafts as ar 
where 
    ar.model LIKE 'Boeing%'
	
/*Sukhoi Superjet:*/
select 
    'Sukhoi Superjet' as make,
    count(distinct ar.model) as model_count
from 
    dst_project.aircrafts as ar 
where 
    ar.model LIKE 'Sukhoi Superjet%'
	
/*Airbus:*/
select 
    'Airbus' as make,
    count(distinct ar.model) as model_count
from 
    dst_project.aircrafts as ar 
where 
    ar.model LIKE 'Airbus%'
	
/*Вопрос 3. В какой части (частях) света находится больше аэропортов?

Europe
Australia
Europe, Asia
Asia*/
select 
    substring(ar.timezone from '#"%#"/%' for '#') as world_part,
    count(*)
from 
    dst_project.airports as ar    
group by
    world_part
	
/*Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id).*/
select 
    flight_id
from 
    dst_project.flights as fl
where 
    not fl.actual_arrival is null
order by    
    (fl.actual_arrival - fl.scheduled_arrival) desc
limit 1

/*Задание 4.4
Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?*/
select
    min(fl.scheduled_departure)
from
    dst_project.flights as fl
	
/*Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?*/
select 
    max(extract (epoch from (fl.scheduled_arrival - fl.scheduled_departure)) / 60)
from 
    dst_project.flights fl

/*Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?*/
select 
    fl.departure_airport,
    fl.arrival_airport
from 
    dst_project.flights fl
order by
    extract (epoch from (fl.scheduled_arrival - fl.scheduled_departure)) desc
limit 1

/*Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах? Секунды округляются в меньшую сторону (отбрасываются до минут).*/
select 
    (avg(extract(epoch from (fl.scheduled_arrival - fl.scheduled_departure)))/60)::int as duration
from 
    dst_project.flights fl

/*Задание 4.5
Вопрос 1. Мест какого класса у SU9 больше всего?

Economy
Business
Standart
Comfort*/
select 
    fare_conditions,
    count(*)  
from 
    dst_project.seats as st   
where
    st.aircraft_code = 'SU9'
group by 
    fare_conditions
    
/*Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?*/
select 
    min(bk.total_amount)
from 
    dst_project.bookings as bk   
    
 
/*Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?*/
select 
    bp.seat_no
from 
    dst_project.tickets as tc
        join dst_project.boarding_passes as bp on tc.ticket_no=bp.ticket_no
where 
    tc.passenger_id = '4313 788533'
	
/*Задание 5.1
Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?*/
select 
    count(*)
from 
    dst_project.airports as ar  
        join dst_project.flights as fl on ar.airport_code  = fl.arrival_airport
where 
    ar.city = 'Anapa' and
    not fl.actual_arrival is null
 
/*Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?*/
select 
    count(*)
from 
    dst_project.airports as ar  
        join dst_project.flights as fl on ar.airport_code  = fl.arrival_airport
where 
    ar.city = 'Anapa' and
    extract(year from fl.actual_arrival) = 2017 and
    extract(month from fl.actual_arrival) in (1,2,12) and
	fl.status not in ('Cancelled')

 
/*Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.*/
select 
    count(*)
from 
    dst_project.airports as ar  
        join dst_project.flights as fl on ar.airport_code  = fl.arrival_airport
where 
    ar.city = 'Anapa' and
    fl.status = 'Cancelled'

/*Вопрос 4. Сколько рейсов из Анапы не летают в Москву?*/
select 
    count(distinct fl.flight_no)
from 
    dst_project.airports as ar  
        join dst_project.flights as fl on ar.airport_code  = fl.departure_airport
            join dst_project.airports as ar2 on fl.arrival_airport = ar2.airport_code
where 
    ar.city = 'Anapa' and
    ar2.city != 'Moscow'
 
 
/*Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?*/
select 
    arc.model
from 
    (select 
        distinct fl.aircraft_code
    from 
        dst_project.airports as ar  
            join dst_project.flights as fl on ar.airport_code = fl.departure_airport
    where 
        ar.city = 'Anapa') as anapa_aircraft
        join dst_project.seats as st on anapa_aircraft.aircraft_code = st.aircraft_code
            join dst_project.aircrafts as arc on st.aircraft_code=arc.aircraft_code
group by 
    1
order by 
    count(st.seat_no) desc
limit 1

/****************************************************************************************************************/
/***************************************** Проект 4. Авиарейсы без потерь ***************************************/
/****************************************************************************************************************/
with 
	/* задаем таблицу портребления топлива в зависимости от типа амолета (кг/час)    */ 
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
	/* получаем таблицу физических параметров (длительность, город вылета/прилета,   */
	/* время вылета/прилета) для каждого полета (flight_id)                          */
    flight_info as
    (
    select 
        row_number() over (order by arr.city,fl.scheduled_departure) as row_num,
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
        extract(year from fl.actual_arrival) = 2017 and
        extract(month from fl.actual_arrival) in (1,2,12) and
	    fl.status not in ('Cancelled') 
    )
,
	/* получаем таблицу количества пассажиров (total, business и economy) и  */   
	/* соответвующу выручку за билатеты для каждого полета (flight_id)       */
    amount as
    (
    select
        tf.flight_id,
        count (*) as pass_count_total,
        sum((tf.fare_conditions = 'Business')::int) as Business_count,
        sum((tf.fare_conditions = 'Economy')::int) as Economy_count,
        sum(tf.amount) as pass_amount_total,
        sum((tf.fare_conditions = 'Business')::int * tf.amount) as Business_amount,
        sum((tf.fare_conditions = 'Economy')::int * tf.amount) as Economy_amount
    from 
        dst_project.ticket_flights as tf
            join dst_project.flights as fl on tf.flight_id=fl.flight_id
    where 
        fl.departure_airport = 'AAQ'
    group by 
        tf.flight_id
    )
,
	/*  получаем таблицу потенциально возможной выручки (total, business и economy)    */ 
	/* в зависимости от типа самолета (aircraft_code)                                  */
    potential_amount as
    (
    select 
        aa.aircraft_code,
        sum((aa.fare_conditions = 'Business')::int * aa.amount * aa.max) as business_potential_amount,
        sum((aa.fare_conditions = 'Economy')::int * aa.amount * aa.max) as economy_potential_amount,
        sum(aa.amount*aa.max) as potential_amount_total
    from 
        (select 
            amn.aircraft_code,
            amn.fare_conditions,    
            amn.amount,
            max(amn.cnt)
        from
            (select
                tf.flight_id,
                fl.aircraft_code,
                tf.fare_conditions,
                tf.amount,
                count(*) as cnt
            from 
                dst_project.ticket_flights as tf
                    join dst_project.flights as fl on tf.flight_id=fl.flight_id
            where 
                fl.departure_airport = 'AAQ'
            group by 
                tf.flight_id,
                fl.aircraft_code,
                tf.fare_conditions,
                tf.amount) 
                    as amn
        group by
            amn.aircraft_code,
            amn.fare_conditions,
            amn.amount
        order by amn.aircraft_code) 
        as aa
    group by 
        aa.aircraft_code
    )
,
    /* получаем таблицу вместимости самолета (total, business и economy) в зависимости  */
    /* от его типа (aircraft_code)                                                      */
    capacity as
    (
    select 
        st.aircraft_code,
        count (*) as capacity_total,
        sum((st.fare_conditions = 'Business')::int) as business_capacity,        
        sum((st.fare_conditions = 'Economy')::int) as economy_capacity
        
    from 
        dst_project.seats as st
    group by 
        st.aircraft_code
    )
,
    /* плучаем таблицу дат бронирований (business и economy) для каждого полета (flight_id)*/
	booking_date as
    (
	with 
        business_booking_date as
        (
        select 
            fl.flight_id,
            json_agg(bk.book_date) as business_booking_date
        from
            dst_project.flights as fl
                join dst_project.ticket_flights as tf on fl.flight_id=tf.flight_id
                    join  dst_project.tickets as tc on tf.ticket_no=tc.ticket_no
                        join dst_project.bookings as bk on tc.book_ref=bk.book_ref
        where
            tf.fare_conditions = 'Business'
        group by 
            fl.flight_id
        )
        ,
        economy_booking_date as
        (
        select 
            fl.flight_id,
            json_agg(bk.book_date) as economy_booking_date
        from
            dst_project.flights as fl
                join dst_project.ticket_flights as tf on fl.flight_id=tf.flight_id
                    join  dst_project.tickets as tc on tf.ticket_no=tc.ticket_no
                        join dst_project.bookings as bk on tc.book_ref=bk.book_ref
        where
            tf.fare_conditions = 'Economy'
        group by 
            fl.flight_id
        )
    select 
        bbd.flight_id,
        bbd.business_booking_date,
        ebd.economy_booking_date    
    from business_booking_date as bbd 
        join economy_booking_date as ebd on bbd.flight_id = ebd.flight_id
	)
/*   итоговый запрос, формирующий датасет       */
select 
	fi.row_num,                 -- № п/п
	fi.flight_id,               -- уникальный индетификатор полета
	fi.departure_from,          -- город вылета
	fi.arrival_to,              -- город прилета
	fi.aircraft_code,           -- код типа самолета
	extract (epoch from (fi.scheduled_arrival - fi.scheduled_departure))/3600 as duration,
	                            -- длительность полета в часах
    extract (epoch from (fi.scheduled_arrival - fi.scheduled_departure))/3600 * 
        32 * fc.consumption as flight_cost,  
                                -- затраты на полет (учитывается только стоимость топлива)
	fi.scheduled_departure,     -- вылет по расписанию
	fi.scheduled_arrival,       -- прилет по расписанию
	fi.actual_departure,        -- действительный вылет
	fi.actual_arrival,          -- действительный прилет
	fc.consumption,             -- расход топлива (кг/час)
	cp.capacity_total,          -- общая вместимость самолета
	cp.business_capacity,       -- вместимость бизнес класса
	cp.economy_capacity,        -- вместимосьб эконом класса
	am.pass_count_total,        -- общее количество пассажиров
	am.business_count,          -- количество пассадиров бизнесс класса
	am.economy_count,           -- количество пассажиров эконом класса
	am.pass_amount_total,       -- общая выручка
	am.business_amount,         -- выручка от бизнесс класса
	am.economy_amount,          -- выручка от эконом класса
	pa.potential_amount_total,  -- возможная общая выручка
	pa.business_potential_amount,   -- возможная выручка от бизнесс класса
	pa.economy_potential_amount,    -- возможная выручка от эконом класса
	bd.business_booking_date,   -- даты бронирований бизнесс класса
	bd.economy_booking_date     -- даты бронирований эконом класса
from flight_info as fi 
	left join fuel_consmpt as fc on fi.aircraft_code=fc.aircraft_code
	left join capacity as cp on fi.aircraft_code=cp.aircraft_code	
	left join amount as am on fi.flight_id=am.flight_id
	left join potential_amount as pa on fi.aircraft_code=pa.aircraft_code
	left join booking_date as bd on fi.flight_id = bd.flight_id
order by 
	row_num