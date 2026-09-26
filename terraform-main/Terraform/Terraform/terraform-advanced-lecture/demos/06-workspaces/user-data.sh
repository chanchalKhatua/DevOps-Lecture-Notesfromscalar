#!/bin/bash
yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

# Create environment-specific content
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${environment} Environment</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px;
            background-color: ${environment == "production" ? "#ff6b6b" : environment == "staging" ? "#4ecdc4" : "#45b7d1"};
            color: white;
        }
        .container { 
            background-color: rgba(0,0,0,0.1); 
            padding: 20px; 
            border-radius: 10px; 
        }
        .info { 
            background-color: rgba(255,255,255,0.1); 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 5px; 
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 ${environment} Environment</h1>
        <div class="info">
            <strong>Environment:</strong> ${environment}<br>
            <strong>Instance ID:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)<br>
            <strong>Availability Zone:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)<br>
            <strong>Instance Type:</strong> \$(curl -s http://169.254.169.254/latest/meta-data/instance-type)<br>
            <strong>Timestamp:</strong> \$(date)
        </div>
        <h2>Workspace Demo Features</h2>
        <ul>
            <li>Environment-specific configuration</li>
            <li>Workspace-based resource naming</li>
            <li>Conditional resource creation</li>
            <li>Environment-aware scaling</li>
        </ul>
    </div>
</body>
</html>
EOF

# Execute the curl commands to get actual values
sed -i 's/\\$(/$/g' /var/www/html/index.html
INSTANCE_ID=\$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=\$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=\$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
TIMESTAMP=\$(date)

sed -i "s/\\\$\(curl -s http:\/\/169\.254\.169\.254\/latest\/meta-data\/instance-id\)/\$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/\\\$\(curl -s http:\/\/169\.254\.169\.254\/latest\/meta-data\/placement\/availability-zone\)/\$AZ/g" /var/www/html/index.html
sed -i "s/\\\$\(curl -s http:\/\/169\.254\.169\.254\/latest\/meta-data\/instance-type\)/\$INSTANCE_TYPE/g" /var/www/html/index.html
sed -i "s/\\\$\(date\)/\$TIMESTAMP/g" /var/www/html/index.html