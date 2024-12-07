import pymysql
from dotenv import load_dotenv
import os

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