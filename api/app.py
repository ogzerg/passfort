from flask import Flask, render_template, redirect, request, session, jsonify
from flask_session import Session
from dotenv import load_dotenv
import os
import random
import datetime
import hashlib
from sms_connection import sendSMS
from DBConnection import DBConnection
import json

app = Flask(__name__)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Load environment variables from .env file
load_dotenv()


def generate_otp():
    return random.randint(100000, 999999)

def check_user_from_db(phone_number):
    db = DBConnection()
    return db.check_user(phone_number)

@app.route("/check_user", methods=["POST"])
def check_user():
    phone_number = request.form.get("phone_number")
    if not phone_number:
        return jsonify({"error": "phone_number is required"}), 400
    if check_user_from_db(phone_number):
        return jsonify({"status": True, "msg": "User found"}), 200
    return jsonify({"status": False, "msg": "User not found"}), 404


# region Registration Process


@app.route("/register_step1", methods=["POST"])
def register_step1():
    phone_number = request.form.get("phone_number")
    if not phone_number:
        return jsonify({"error": "phone_number is required"}), 400
    if check_user_from_db(phone_number):
        return jsonify({"status": False, "msg": "User already exists"}), 400
    otp = generate_otp()
    session["otp"] = otp
    session["phone_number"] = phone_number
    res = sendSMS(phone_number, f"Your OTP Code is: {otp}")
    if res:
        return jsonify({"status": True, "msg": "OTP sent successfully"})
    return jsonify({"status": False, "msg": "OTP sending failed"}), 400


@app.route("/register_step2", methods=["POST"])
def register_step2():
    otp = request.form.get("otp")
    if not otp:
        return jsonify({"error": "otp is required"}), 400
    if session.get("otp") == int(otp):
        db = DBConnection()
        lastRow = db.register_user(session.get("phone_number"), request.remote_addr)
        session.clear()
        session["user_id"] = lastRow
        return jsonify({"status": True, "msg": "User registered successfully"})
    return jsonify({"status": False, "msg": "OTP verification failed"}), 400
# endregion


# region Login Process
@app.route("/login_step1", methods=["POST"])
def login_step1():
    phone_number = request.form.get("phone_number")
    if not phone_number:
        return jsonify({"error": "phone_number is required"}), 400
    if not check_user_from_db(phone_number):
        return jsonify({"status": False, "msg": "User not found"}), 400
    otp = generate_otp()
    session["otp"] = otp
    session["phone_number"] = phone_number
    res = sendSMS(phone_number, f"Your OTP Code is: {otp}")
    if res:
        return jsonify({"status": True, "msg": "OTP sent successfully"})
    return jsonify({"status": False, "msg": "OTP sending failed"}), 400

@app.route("/login_step2", methods=["POST"])
def login_step2():
    otp = request.form.get("otp")
    if not otp:
        return jsonify({"error": "otp is required"}), 400
    if session.get("otp") == int(otp):
        db = DBConnection()
        user = db.get_user_by_phone_number(session.get("phone_number"))
        session.clear()
        session["user_id"] = user[0]
        return jsonify({"status": True, "msg": "User logged in successfully"})
    return jsonify({"status": False, "msg": "OTP verification failed"}), 400

# endregion

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
