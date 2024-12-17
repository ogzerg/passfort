# PassFort

PassFort is a TOTP-based two-factor authentication and password management project. This project includes a mobile application and a Windows application.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Python 3.x
- Required dependencies listed in `requirements.txt`

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/ogzerg/passfort.git
    ```

2. Navigate to the project directory:
    ```sh
    cd passfort
    ```

3. Install the dependencies for the API:
    ```sh
    cd api
    pip install -r requirements.txt
    ```

4. Install the dependencies for the mobile application:
    ```sh
    cd ../mobile_app
    flutter pub get
    ```

5. Install the dependencies for the Windows application:
    ```sh
    cd ../windows_app
    flutter pub get
    ```

6. Set Environment Variables:
    - Create a `.env` file in the `api` directory and add the following variables:
        ```
        DBHOST
        DBUSER
        DBPASS
        DBASE
        JWT_SECRET
        ```
    - Create a `.env` file in the `mobile_app` directory and add the following variables:
        ```
        SERVER_URL
        SERVER_PORT
        WS_URL
        WS_PORT
        RSA_PUBLIC_KEY
        RSA_PRIVATE_KEY
        ```
    - Create a `.env` file in the `windows_app` directory and add the following variables:
        ```
        WS_URL
        WS_PORT
        RSA_PUBLIC_KEY
        RSA_PRIVATE_KEY
        ```

### Running the Project

#### API And WebSocket Server

To run the API, navigate to the [api](./api) directory and execute:
```sh
python app.py
python soket.py
```