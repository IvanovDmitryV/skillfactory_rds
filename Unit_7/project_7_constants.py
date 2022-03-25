path = './Project_7_data/'
# path = '/kaggle/input/.....'

RANDOM_SEED = 42

# service=Service('C:/Users/GANSOR-PC/chromium/chromedriver.exe') # C:\Users\GANSOR-PC

executable_path = 'C:/Users/GANSOR-PC/chromium/chromedriver.exe'

marks_for_parsing = ['SKODA', 'AUDI', 'HONDA', 'VOLVO', 'BMW', 'NISSAN', 'INFINITI',
       'MERCEDES', 'TOYOTA', 'LEXUS', 'VOLKSWAGEN', 'MITSUBISHI']

data_columns = ['bodyType', 'brand', 'car_url', 'color', 'description', 'engineDisplacement', 'enginePower', 
                      'equipment_dict','fuelType', 'mileage', 'modelDate', 'model_name', 'numberOfDoors', 
                      'productionDate', 'sell_id', 'vehicleTransmission', 'vendor', 
                      'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль', 'offerprice']
test_0909_uni_test = ['bodyType', 'brand', 'color', 'engineDisplacement', 'enginePower', 
                'equipment_dict','fuelType', 'mileage', 'modelDate', 'model_name', 'numberOfDoors', 
                'productionDate', 'vehicleTransmission', 'vendor', 
                'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль']
test_0909_uni_0909 = ['bodyType', 'brand', 'color', 'engineDisplacement', 'enginePower', 
                 'Комплектация','fuelType', 'mileage', 'modelDate', 'model', 'numberOfDoors', 
                'productionDate', 'vehicleTransmission', 
                'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль', 'price']