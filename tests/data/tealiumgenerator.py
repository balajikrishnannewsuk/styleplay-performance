import csv
from faker import Faker
import datetime

def datagenerate(records, headers):
    fake = Faker('en_GB')  
    with open("tealium.csv", 'wt') as csvFile:
        writer = csv.DictWriter(csvFile, fieldnames=headers)
        writer.writeheader()
        for i in range(records):
            full_name = fake.name()
            FLname = full_name.split(" ")
            Fname = FLname[0]
            Lname = FLname[1]
            tealiumId = "017f535"+Lname+"7000b7e"
            writer.writerow({
                    "tealium_Id" : tealiumId,
                    })
    
if __name__ == '__main__':
    records = 10000
    headers = ["tealium_Id"]
    datagenerate(records, headers)
    print("TealiumId CSV generation complete!")