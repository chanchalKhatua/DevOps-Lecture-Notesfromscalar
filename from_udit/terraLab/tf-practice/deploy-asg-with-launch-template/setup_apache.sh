#!/bin/bash
# Update the package list
sudo apt-get update -y

# Install Apache
sudo apt-get install apache2 -y

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a custom web page
echo "<h1>Hello from your Apache Web Server!</h1>" | sudo tee /var/www/html/index.html