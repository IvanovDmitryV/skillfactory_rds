path = './Project_7_data/'
# path = '/kaggle/input/.....'

#
RANDOM_SEED = 42
#
executable_path = 'C:/Users/GANSOR-PC/chromium/chromedriver.exe'
#
marks_for_parsing = ['SKODA', 'AUDI', 'HONDA', 'VOLVO', 'BMW', 'NISSAN', 'INFINITI',
       'MERCEDES', 'TOYOTA', 'LEXUS', 'VOLKSWAGEN', 'MITSUBISHI']
#
data_columns = ['bodyType', 'brand', 'car_url', 'color', 'description', 'engineDisplacement', 'enginePower', 
                      'equipment_dict','fuelType', 'mileage', 'modelDate', 'model_name', 'numberOfDoors', 
                      'productionDate', 'sell_id', 'vehicleTransmission', 'vendor', 
                      'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль', 'price']
# 
externdata_train_uni_columns = ['bodyType', 'brand', 'color', 'engineDisplacement', 'enginePower', 
                 'Комплектация','fuelType', 'mileage', 'modelDate', 'model', 'numberOfDoors', 
                'productionDate', 'vehicleTransmission', 
                'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль', 'price']
#
externdata_test_uni_columns = ['bodyType', 'brand', 'color', 'engineDisplacement', 'enginePower', 
                'equipment_dict','fuelType', 'mileage', 'modelDate', 'model_name', 'numberOfDoors', 
                'productionDate', 'vehicleTransmission', 'vendor', 
                'Владельцы', 'Владение', 'ПТС', 'Привод', 'Руль']
#
parsdata_uni_columns = ['model_name', 'equipment_dict', 'brand', 'modelDate', 
                 'productionDate', 'ПТС','mileage', 'car_url', 'engineDisplacement', 
                 'numberOfDoors', 'enginePower', 'vendor', 'color', 'vehicleTransmission', 
                 'sell_id', 'Владельцы', 'Руль', 'bodyType', 'Привод']
#

