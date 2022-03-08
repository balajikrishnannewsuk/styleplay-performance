import csv
from faker import Faker
import datetime

def datagenerate(records, headers):
    fake = Faker('en_GB')  
    with open("email.csv", 'wt') as csvFile:
        writer = csv.DictWriter(csvFile, fieldnames=headers)
        writer.writeheader()
        for i in range(records):
            full_name = fake.name()
            FLname = full_name.split(" ")
            Fname = FLname[0]
            Lname = FLname[1]
            domain_name = "@yopmail.com"
            userId = "Test."+ Fname+ Lname + domain_name
            
            writer.writerow({
                    "emailId" : userId,
                    })
    
if __name__ == '__main__':
    records = 10000
    headers = ["emailId"]
    datagenerate(records, headers)
    print("EmailID CSV generation complete!")