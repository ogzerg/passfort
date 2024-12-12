import pymysql
from dotenv import load_dotenv
import os
import json

load_dotenv()

class DBConnection:
    def __init__(self):
        self.conn = pymysql.connect(
            host=os.getenv("DBHOST"), user=os.getenv("DBUSER"), password=os.getenv("DBPASS"), db=os.getenv("DBASE")
        )
        self.cursor = self.conn.cursor()

    def check_user(self, phone_number) -> bool:
        self.cursor.execute(f"SELECT * FROM users WHERE phoneNumber = '{phone_number}'")
        user = self.cursor.fetchone()
        if user:
            return True
        return False

    def register_user(self, phone_number, ip_address) -> int:
        self.cursor.execute(
            f"INSERT INTO users (phoneNumber, registerDate, registerIP) VALUES ('{phone_number}', NOW(), '{ip_address}')"
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_user_by_phone_number(self, phone_number) -> tuple:
        self.cursor.execute(f"SELECT id FROM users WHERE phoneNumber = '{phone_number}'")
        return self.cursor.fetchone()
    
    def insert_password(self, user_id,service, password) -> None:
        self.cursor.execute(f"INSERT INTO user_passwords (user_id,service, password_hash) VALUES ({user_id},'{service}' ,'{password}')")
        self.conn.commit()
        
    def get_users_password(self, user_id) -> list:
        self.cursor.execute(f"SELECT service, password_hash FROM user_passwords WHERE user_id = {user_id}")
        passwords = self.cursor.fetchall()
        return json.dumps([{"id": idx + 1, "service": service, "password": password} for idx, (service, password) in enumerate(passwords)])