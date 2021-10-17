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
    extract(month from fl.actual_arrival) in (1,2,12)
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