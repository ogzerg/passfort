CREATE TABLE TwoFackKeys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    userId INT NOT NULL,
    serviceName VARCHAR(255),
    serviceKey VARCHAR(255),
    FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE
);