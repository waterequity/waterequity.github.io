import csv
import numpy

nbOfRow = 20

header = ['name', 'lat', 'long', 'waterRationing', 'waterConsumption', 'waterRationningPerCapita',
 		'waterConsumptionPerCapita', 'droughtIndex', 'groundWaterLevel', 'agroWorker',
  		'averageIncome', 'householdSize', 'GINIIndex', 'race']

data = []

for row in range(0, nbOfRow):
	temp = list(numpy.random.random_sample((len(header),)))
	name = 'radom' + str(row)
	temp.insert(0, name)
	data.append(temp)

with open('data.csv', 'w') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',')
    spamwriter.writerow(header)
    for row in data:
    	spamwriter.writerow(row)