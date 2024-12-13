import pymysql
from dotenv import load_dotenv
import os
import json

load_dotenv()


class DBConnection:
    def __init__(self):
        self.conn = pymysql.connect(
            host=os.getenv("DBHOST"),
            user=os.getenv("DBUSER"),
            password=os.getenv("DBPASS"),
            db=os.getenv("DBASE"),
        )
        self.cursor = self.conn.cursor()

    def check_user(self, phone_number) -> bool:
        """
        Checks if a user with the given phone number exists in the database.

        Args:
            phone_number (str): The phone number of the user to check.

        Returns:
            bool: True if the user exists, False otherwise.
        """
        self.cursor.execute(
            "SELECT * FROM users WHERE phoneNumber = %s", (phone_number,)
        )
        user = self.cursor.fetchone()
        if user:
            return True
        return False

    def register_user(self, phone_number, ip_address) -> int:
        """
        Registers a new user in the database with the provided phone number and IP address.

        Args:
            phone_number (str): The phone number of the user to register.
            ip_address (str): The IP address from which the user is registering.

        Returns:
            int: The ID of the newly registered user.
        """
        self.cursor.execute(
            "INSERT INTO users (phoneNumber, registerDate, registerIP) VALUES (%s, NOW(), %s)",
            (phone_number, ip_address),
        )
        self.conn.commit()
        return self.cursor.lastrowid

    def get_user_by_phone_number(self, phone_number) -> tuple:
        """
        Retrieve a user by their phone number.

        Args:
            phone_number (str): The phone number of the user to retrieve.

        Returns:
            tuple: A tuple containing the user's ID if found, otherwise None.
        """
        self.cursor.execute(
            "SELECT id FROM users WHERE phoneNumber = %s", (phone_number,)
        )
        return self.cursor.fetchone()

    def insert_password(self, user_id, service, login, password) -> None:
        """
        Inserts a new password entry into the user_passwords table.

        Args:
            user_id (int): The ID of the user.
            service (str): The name of the service for which the password is used.
            login (str): The login/username for the service.
            password (str): The password to be stored (should be hashed before storing).

        Returns:
            None
        """
        self.cursor.execute(
            "INSERT INTO user_passwords (user_id, service, login, password_hash) VALUES (%s, %s, %s, %s)",
            (user_id, service, login, password),
        )
        self.conn.commit()

    def get_users_password(self, user_id) -> json:
        """
        Retrieve the passwords for a given user from the database.

        Args:
            user_id (int): The ID of the user whose passwords are to be retrieved.

        Returns:
            json: A JSON string containing a list of dictionaries, each representing a password entry.
                  Each dictionary contains the following keys:
                  - id (int): The index of the password entry.
                  - service (str): The name of the service.
                  - login (str): The login name for the service.
                  - password (str): The hashed password for the service.
        """
        self.cursor.execute(
            "SELECT service, login, password_hash FROM user_passwords WHERE user_id = %s",
            (user_id,),
        )
        passwords = self.cursor.fetchall()
        return json.dumps(
            [
                {
                    "id": idx + 1,
                    "service": service,
                    "login": login,
                    "password": password,
                }
                for idx, (service, login, password) in enumerate(passwords)
            ]
        )

    def get_user_informations(self, user_id) -> json:
        """
        Retrieve the user informations from the database.

        Args:
            user_id (int): The ID of the user whose informations are to be retrieved.

        Returns:
            json: A JSON string containing a dictionary, representing a user entry.
                  The dictionary contains the following keys:
                  - id (int): The index of the user entry.
                  - phoneNumber (str): The phone number of the user.
                  - registerDate (str): The register date of the user.
                  - registerIP (str): The register IP of the user.
        """
        self.cursor.execute(
            "SELECT phoneNumber, registerDate, registerIP FROM users WHERE id = %s",
            (user_id,),
        )
        user = self.cursor.fetchone()
        return json.dumps(
            {
                "phoneNumber": user[0][:4] + "*" * (len(user[0]) - 4) + user[0][-2:],
                "registerDate": str(user[1]),
                "registerIP": user[2],
            }
        )
