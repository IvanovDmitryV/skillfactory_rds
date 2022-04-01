import pandas as pd
import numpy as np
import json
import time
import re
import matplotlib.pyplot as plt
import seaborn as sns

from project_7_constants import *

from datetime import datetime
from datetime import date

from catboost import CatBoostRegressor
from sklearn.preprocessing import LabelEncoder
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from tqdm import tqdm
from bs4 import BeautifulSoup

def describe_df(df):
    '''
    Вывод простой статистки DataFrame
    '''
    desc = df.describe(include='all',percentiles=[0.5]).drop(index=['mean','std','50%']).T 
    desc['type'] = [type(x) for x in df.iloc[0]]
    desc['NaN_prop'] = round(df.isna().sum()/len(df),3)
    desc.unique = df.nunique()
    desc.top = df.mode(axis=0).iloc[0]
    desc.top = [str(x)[:30] for x in df.mode(axis=0).iloc[0]]

    desc.freq = [df[col].value_counts().iloc[0] for col in  df.columns]
    
    return desc

def get_marks_models():
    '''
    возврашщает pd.Series в котором 
    индекс - название марки автомобиоя, 
    значения - списки названий моделей для каждой маркию
    
    '''
    url_for_marks_models = 'https://auto.ru/catalog/cars/all/'
    marks_models = dict() 

    driver = webdriver.Chrome(executable_path)  # открываем driver
    driver.maximize_window()                    # масксимизируем окно

    for pages_num in range(1,20):
        
        if pages_num==1: url = url_for_marks_models + '?view_type=list'
        else:            url = url_for_marks_models + '?page_num='+ str(pages_num) +'&view_type=list'
        
        driver.get(url)                         # открываем страницу по url
        res = driver.execute_script("return document.body.innerHTML;") # получаем html
        soup = BeautifulSoup(res, 'html.parser') # создаем обьект bs4.BeautifulSoup
        
        # Список html-ек перечня моделей каждой марки на странице:
        marks_on_page_list = soup.find_all('dd', class_='catalog-all-text-list__desc') 
    
        if not marks_on_page_list: 
            break
        
        for mark_html in marks_on_page_list:
            models_of_mark = mark_html.find_all('a', class_='link_theme_auto') # список html-ек моделей марки
        
            link_for_mark_name = models_of_mark[0].get('href')  # линк первой модели, содержит обозначене 
                                                                # марки на auto.ru
            mark_start = link_for_mark_name.find('cars/') + 5   # первый символ обозначеня марки
            mark_end = link_for_mark_name.find('/', mark_start) # последний символ обозначения марки
            mark_name = link_for_mark_name[mark_start:mark_end].upper() # получение обозначения марки  
        
            models_list = []
            for model in models_of_mark:
                link_theme_auto = model.get('href')                 # линк модели, содержит обозначение модели 
                                                                    # на auto.ru
                model_start = mark_end+1                            # первый символ обозначения модели
                model_end = link_theme_auto.find('/', model_start)  # последний символ обозначения модели
                model_name = link_theme_auto[model_start:model_end].upper() # получение обозначения модели
                models_list.append(model_name)
                
            marks_models[mark_name] = models_list
        
        time.sleep(1) 
    # Закрываем процесс браузера:
    driver.quit()
    return marks_models

def get_generation_year(model_url,driver):
    '''
    возврашщает pd.DataFrame  в котором: 
        full_name - полное название модели с указанием поколения, 
        bodytype - тип кузова поколения модели
        generation_year - год начала выпуска поколения
        
    model_url - ссылка на страницу со списокм поколений модели
    
    '''
    driver.get(model_url+'?output_type=models_list') # открываем страницу по url
    
    models_list_res = driver.execute_script("return document.body.innerHTML;") # получаем html        
    
    # создаем обьект bs4.BeautifulSoup из html: 
    models_list_bs = BeautifulSoup(models_list_res, 'html.parser') 
    
    # получаем список html-ек описаний для всех поколений модели  
    posting_tag = models_list_bs.find_all('h3',class_ = "ListingItemGroup__title")
    
    # формируем списки с указанием поколения модели, типом кузова поколения и годом начала выпуска поколения
    # (необходимость указания типа кузова вызвана тем, что разные кузова зачастую переходят на следующее 
    #  поколение в разные годы)
    data = [
    [tag.find('a',class_ = 'ListingItemTitle__link').text,             # поколение
     tag.find('div',class_ = "ListingItemGroup__subtitle").text[:      # кузов
        tag.find('div',class_ = "ListingItemGroup__subtitle").text.find(' •')],
     int(tag.find('div',class_ = "ListingItemGroup__subtitle").text    # год
        [tag.find('div',class_ = "ListingItemGroup__subtitle").text.find('(')+1:
        tag.find('div',class_ = "ListingItemGroup__subtitle").text.find('(')+5])] 
        for tag in posting_tag]
    result = pd.DataFrame(data,columns = ['full_name','bodytype','generation_year'])
    return result 

def get_model_generation_year(marks_models_for_parsing):
    '''
    возврашщает pd.DataFrame  в котором: 
        full_name - полное название марки и модели с указанием поколения 
        bodytype - тип кузова поколения модели
        generation_year - год начала выпуска поколения
    
    marks_models_for_parsing - pd.Series в котором
        индекс: марка автомобиля
        значение: список моделей данной марки
    '''  
    driver = webdriver.Chrome(executable_path)  # запускаем процесс браузера
    driver.maximize_window()                    # масксимизируем окно    
    
    model_generation_year = pd.DataFrame(columns = ['full_name','bodytype','generation_year'])
    
    for mark in marks_models_for_parsing:
        print(mark, end=' | ')
        
        for model in marks_models_for_parsing[mark]:
            model_url = 'https://auto.ru/moskva/cars/' + mark.lower() + '/' + model.lower() + '/used/'
            tmp = get_generation_year(model_url,driver)
            model_generation_year = model_generation_year.append(tmp)
            time.sleep(1)
            
    driver.quit()    # закрываем процесс браузера
    
    return model_generation_year

def get_features_from_ticket(ticket_url, driver):
    '''
    возвращает pd.Series с признакамии полученными из карточки обьявления
    
    ticket_url: str, ссылка на страницу обьявления
    driver: WebDriver, selenium.webdriver.chrome.webdriver.WebDriver
    '''
    features = pd.Series(index = data_columns)
    # получем html карточки текщего обьявления
    driver.get(ticket_url)
    # Находим и кликаем 'Все опции'
    try:
        butt = driver.find_element(By.CLASS_NAME, 'ComplectationGroupsDesktop__cut') 
        butt.click() 
    except Exception: pass
    # Получаем содержимое html-страницы:
    ticket_res = driver.execute_script("return document.body.innerHTML;")
    # Закрываем процесс браузера:
    # создаем обьект bs4.BeautifulSoup из html карточки текщего обьявления
    ticket_bs = BeautifulSoup(ticket_res, 'html.parser')  # 'html.parser'
    # проверка корректности результата BeautifulSoup
    if ticket_bs:
    # получение признаков из карточки текущего обьявления
        # bodyType      
        try: features['bodyType'] = ticket_bs.find('li',class_='CardInfoRow_bodytype').find('a').text
        except Exception: features['bodytype'] = np.NaN
        # brand        
        try: features['brand'] = ticket_url.split('/')[-4].upper()
        except Exception: features['brand'] = np.NaN
        # car_url
        features['car_url'] = ticket_url
        # color        
        try: features['color'] = ticket_bs.find('li',class_='CardInfoRow_color').find('a').text
        except Exception: features['color'] = np.NaN 
        # description
        try:
            rows = ticket_bs.find('div',class_='CardDescriptionHTML').find_all('span')
            features['description'] = '\n'.join([row.text for row in rows])
        except Exception: features['description'] = np.NaN
        #engineDisplacement            
        try: 
            engineDisplacement = ticket_bs.find('li',class_='CardInfoRow_engine').find('div').text.split(' / ')[0]
            features['engineDisplacement'] =  re.sub("[^\d.]", "", engineDisplacement)
        except Exception: features['engineDisplacement'] = np.NaN
        # enginePower
        try: 
            enginePower = ticket_bs.find(
                'li',class_='CardInfoRow_engine').find('div').text.split(' / ')[1]
            features['enginePower'] = re.sub("\D", "", enginePower)
        except Exception: features['enginePower'] = np.NaN            
        # equipment_dict 
        try: 
            complectation_groups = ticket_bs.find(
                'div',class_='ComplectationGroupsDesktop__row').find_all(
                'div',class_='ComplectationGroupsDesktop__group')
            features['equipment_dict'] = {
                group.text.split('•')[0]: group.text.split('•')[1:] for group in complectation_groups}
        except Exception: features['equipment_dict'] = np.NaN             
        # fuelType
        try: features['fuelType'] = ticket_bs.find(
            'li',class_='CardInfoRow_engine').find('div').text.split(' / ')[2]
        except Exception: features['fuel_type'] = np.NaN
        # mileage
        try:
            mileage = ticket_bs.find('li',class_='CardInfoRow_kmAge').find_all('span')[1].text
            features['mileage'] = re.sub("\D", "", mileage)
        except Exception: features['mileage'] = np.NaN            
        # model_name
        try: features['model_name'] = ticket_url.split('/')[-3].upper()
        except Exception: features['model_name'] = np.NaN            
        # numberOfDoors
        try:
            numberOfDoors_tag = ticket_bs.find('li',class_='CardInfoRow_bodytype').find('a')
            numberOfDoors_pre = re.findall('\d', numberOfDoors_tag.text)
            features['numberOfDoors'] = int(numberOfDoors_pre[0])
        except Exception: features['numberOfDoors'] = np.NaN
        # productionDate
        try: features['productionDate'] = ticket_bs.find(
            'li',class_='CardInfoRow_year').find('a').text
        except Exception: features['productionDate'] = np.NaN
        # sell_id
        try:         
            invers_ticket_url = ticket_url[::-1]
            id_start, id_end = invers_ticket_url.find('/',1) , invers_ticket_url.find('-')+1
            features['sell_id'] = ticket_url[-id_start:-id_end]
        except Exception: features['sell_id'] = np.NaN
        # vehicleTransmission
        try:
            features['vehicleTransmission'] = (ticket_bs.find('li',class_='CardInfoRow_transmission').
                                               find_all('span')[1].text)
        except Exception: features['vehicleTransmission'] = np.NaN            
        # vendor
        european = ['SKODA', 'AUDI',  'VOLVO', 'BMW', 'MERCEDES', 'VOLKSWAGEN']
        japanese = ['HONDA','NISSAN','TOYOTA','INFINITI',  'LEXUS', 'MITSUBISHI']
        if features['brand'] in european :  features['vendor'] = 'EUROPEAN'
        elif features['brand'] in japanese :  features['vendor'] = 'JAPANESE'
        else: features['vendor'] = 'NAN'  
        # Владение
        try: features['Владение'] = ticket_bs.find('li',class_='CardInfoRow_owningTime').find_all('span')[1].text
        except Exception: features['Владение'] = np.NaN             
        # Владельцы
        try: features['Владельцы'] = ticket_bs.find('li',class_='CardInfoRow_ownersCount').find_all('span')[1].text
        except Exception: features['Владельцы'] = np.NaN            
        # ПТС
        try: features['ПТС'] = ticket_bs.find('li',class_='CardInfoRow_pts').find_all('span')[1].text
        except Exception: features['ПТС'] = np.NaN               
        # Привод
        try: features['Привод'] = ticket_bs.find('li',class_='CardInfoRow_drive').find_all('span')[1].text
        except Exception: features['Привод'] = np.NaN            
        # Руль
        try: features['Руль'] = ticket_bs.find('li',class_='CardInfoRow_wheel').find_all('span')[1].text 
        except Exception: features['Руль'] = np.NaN         
        # Цена предложения
        try:
            offerprice = ticket_bs.find('span',class_='OfferPriceCaption__price').text
            features['offerprice'] = re.sub("\D", "", offerprice)
        except Exception: features['offerprice'] = np.NaN
        # modelDate              
        try:
            modelDate_tag = ticket_bs.find_all('a',class_='CardBreadcrumbs__itemText')
            features['modelDate'] = (modelDate_tag[2].text.strip() + ' ' +
                                     modelDate_tag[3].text.strip() + ' ' +
                                     modelDate_tag[4].text.strip())  
        except Exception: features['modelDate'] = np.NaN   
    return features

def externdata_train_bodyType_uni(x):
    res=[]
    x = x.lower() if type(x) == str else x  # <================
    try:
        for body_type in test.bodyType.unique():
            if body_type in x:
                res.append(body_type)
    except Exception: return x
    if not res: 
        return x.split()[0]
    return max(res)

def externdata_train_engineDisplacement_uni(x):
    x = float(re.sub("[^\d.]", r'', x)) if re.sub("[^\d.]", r'', x) else 0
    if x >= 7: x = 0
    return x

def externdata_train_equipment_uni(x):
    point = "'available_options': "
    start = x.find(point)+len(point)+2
    finish = x.find("]",start) - 1
    return x[start:finish].split("', '")

def externdata_test_ownership_uni(x):
    try:
        digits = re.findall('\d+',x) 
        if len(digits) == 2: res = int(digits[0])*12 + int(digits[1])
        elif len(digits) == 1 and 'месяц' in x: res = int(digits[0])
        elif len(digits) == 1 and 'месяц' not in x: res = int(digits[0])*12
    except Exception: res = 0   
    return res

def externdata_train_ownership_uni(x):
    tmp = json.loads(x.replace("'",'"'))  if x==x else {'year': 2020, 'month': 9}
    res = (2020 - tmp['year'])*12 + tmp['month'] - 9
    if res<0: res = 0
    return res


def externdata_train_unification(df_to_proc):
    df = df_to_proc.copy()[externdata_train_uni_columns]
    color_codes = {'040001': 'чёрный','FAFBFB': 'белый', '0000CC': 'синий', 
                   '200204': 'коричневый', 'EE1D19': 'красный', 'CACECB': 'серый',
                   'C49648': 'бежевый', '97948F': 'серебристый', 'FFD600': 'жёлтый',
                   'FF8649': 'оранжевый', '22A0F8': 'голубой','FFC0CB': 'розовый', 
                   'DEA522': 'золотистый', '007F00': 'зелёный', '660099': 'пурпурный',
                   '4A2197': 'фиолетовый'}
    transmission_dict = {'MECHANICAL':'механическая', 'AUTOMATIC':'автоматическая', 
                         'ROBOT':'роботизированная','VARIATOR':'вариатор'}
    vendor_dict = {'AUDI':'EUROPEAN','BMW':'EUROPEAN','HONDA':'JAPANESE','INFINITI':'JAPANESE',
                   'LEXUS':'JAPANESE','MERCEDES':'EUROPEAN','MITSUBISHI':'JAPANESE',
                   'NISSAN':'JAPANESE','SKODA':'EUROPEAN','TOYOTA':'JAPANESE',
                   'VOLKSWAGEN':'EUROPEAN','VOLVO':'EUROPEAN'}
    PTS_dict = {'ORIGINAL': 'Оригинал', 'DUPLICATE': 'Дубликат'}
    wheel_dict = {'LEFT':'Левый', 'RIGHT':'Правый'}
    # bodyType
    df.dropna(subset=['bodyType'],inplace=True)
    df.bodyType = df.bodyType.apply(externdata_train_bodyType_uni)
    # color
    df.color = df.color.map(color_codes)
    # engineDisplacement
    df.engineDisplacement = df.engineDisplacement.apply(externdata_train_engineDisplacement_uni)
    # enginePower
    df.enginePower = df.enginePower.astype(int)
    # equipment_dict
    df['equipment_dict'] = df.Комплектация.apply(externdata_train_equipment_uni)
    df.drop(columns=['Комплектация'],inplace=True)
    # modelDate 
    df.modelDate = df.modelDate.astype(int)
    # model_name
    df['model_name'] = df.model
    df.drop(columns=['model'],inplace=True)
    # numberOfDoors
    df.numberOfDoors = df.numberOfDoors.astype(int)
    # vehicleTransmission
    df.vehicleTransmission = df.vehicleTransmission.map(transmission_dict)
    # vendor
    df['vendor'] = df.brand.map(vendor_dict)
    # Владение
    df.Владение = df.Владение.apply(externdata_train_ownership_uni)
    # ПТС
    df.ПТС = df.ПТС.map(PTS_dict)
    # Руль
    df.Руль = df.Руль.map(wheel_dict)
    
    return df

def externdata_test_unification(df_to_proc):
    test = df_to_proc.copy()[externdata_test_uni_columns]
    owner_dict = {'3 или более': 3., '2\xa0владельца': 2.,'1\xa0владелец': 1.}
    # engineDisplacement
    test.engineDisplacement = test.engineDisplacement.apply(
        lambda x: float(x[:-4]) if x[:-4] else np.NaN) 
    # enginePower
    test.enginePower = test.enginePower.apply(lambda x: int(x[:-4]))
    # equipment_dict
    test.equipment_dict = test.equipment_dict.apply(
        lambda x: list(json.loads(x).keys()) if x==x else [])
    # Владельцы
    test.Владельцы = test.Владельцы.map(owner_dict)
    # Владение
    test.Владение = test.Владение.apply(externdata_test_ownership_uni)
    return test

def parsdata_train_uniifcation(df_to_proc):
    pars = df_to_proc.copy()[parsdata_uni_columns+['offerprice']] # <===== ПОСТАВИТЬ СПИСОК КОЛОНОК
    # modelDate
    model_generation_year = pd.read_csv(".\Project_7_data\model_generation_year.csv")
    model_generation_year = dict(zip(model_generation_year.full_name + ' ' + model_generation_year.bodytype,
             model_generation_year.generation_year))
#     pars.modelDate = (pars.modelDate + ' ' + pars.bodyType).map(model_generation_year) 
    pars.modelDate = pd.Series(
        [x+' '+y if x==x else x for x,y in zip(pars.modelDate,pars.bodyType)]).\
        map(model_generation_year)
    # Владельцы
    owner_dict = {
        '3 или более': 3., 
        '2\xa0владельца': 2.,
        '1\xa0владелец': 1.}
    pars.Владельцы = pars.Владельцы.map(owner_dict)
    # equipment_dic
    pars.equipment_dict = pars.equipment_dict[:50].apply(
        lambda x: pd.Series(list(json.loads(x.replace("'",'"')).values())).sum()
        if x==x else x)    
    
    return pars

def parsdata_test_uniifcation(df_to_proc):
    test = df_to_proc.copy()[parsdata_uni_columns] # <===== ПОСТАВИТЬ СПИСОК КОЛОНОК
    # engineDisplacement
    test.engineDisplacement = test.engineDisplacement.apply(
        lambda x: float(x[:-4]) if x[:-4] else np.NaN)
    # modelDate
    test.modelDate = test.modelDate.astype(float)
    # productionDate
    test.productionDate = test.productionDate.astype(float)
    # numberOfDoors
    test.numberOfDoors = test.numberOfDoors.astype(float)
    # Владельцы
    owner_dict = {
        '3 или более': 3., 
        '2\xa0владельца': 2.,
        '1\xa0владелец': 1.}
    test.Владельцы = test.Владельцы.map(owner_dict)
    # mileage
    test.mileage = test.mileage.astype(float) 
    # enginePower
    test.enginePower = test.enginePower.apply(lambda x: float(x[:-4]))
    # equipment_dic
    test.equipment_dict = test.equipment_dict.apply(
        lambda x: list(json.loads(x).keys()) if x==x else [])
    
    return test
