#!/bin/bash
yum update -y
yum install -y nodejs npm git mysql

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create application directory
mkdir -p /opt/webapp
cd /opt/webapp

# Create a simple Node.js application
cat > package.json << 'EOF'
{
  "name": "webapp",
  "version": "1.0.0",
  "description": "Sample web application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "mysql2": "^3.6.0",
    "aws-sdk": "^2.1400.0"
  }
}
EOF

cat > app.js << 'EOF'
const express = require('express');
const mysql = require('mysql2/promise');
const AWS = require('aws-sdk');

const app = express();
const port = 3000;

// Database configuration
const dbConfig = {
  host: '${db_endpoint}',
  user: '${db_username}',
  password: '${db_password}',
  database: '${db_name}'
};

// AWS S3 configuration
const s3 = new AWS.S3();
const bucketName = '${s3_bucket}';

app.use(express.json());
app.use(express.static('public'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    environment: '${environment}',
    project: '${project_name}'
  });
});

// Home page
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>${project_name} - ${environment}</title></head>
      <body style="font-family: Arial, sans-serif; margin: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
        <div style="background: rgba(255,255,255,0.1); padding: 30px; border-radius: 10px;">
          <h1>🚀 ${project_name}</h1>
          <h2>Environment: ${environment}</h2>
          <p>Instance ID: $${process.env.EC2_INSTANCE_ID || 'Unknown'}</p>
          <p>Timestamp: $${new Date().toISOString()}</p>
          <div style="margin-top: 20px;">
            <a href="/api/users" style="color: #fff; text-decoration: none; background: rgba(255,255,255,0.2); padding: 10px 20px; border-radius: 5px; margin-right: 10px;">View Users</a>
            <a href="/health" style="color: #fff; text-decoration: none; background: rgba(255,255,255,0.2); padding: 10px 20px; border-radius: 5px;">Health Check</a>
          </div>
        </div>
      </body>
    </html>
  `);
});

// API endpoint to get users from database
app.get('/api/users', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM users LIMIT 10');
    await connection.end();
    res.json(rows);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database connection failed' });
  }
});

// API endpoint to create a user
app.post('/api/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    const connection = await mysql.createConnection(dbConfig);
    const [result] = await connection.execute(
      'INSERT INTO users (name, email, created_at) VALUES (?, ?, NOW())',
      [name, email]
    );
    await connection.end();
    res.json({ id: result.insertId, name, email });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port $${port}`);
  console.log(`Environment: ${environment}`);
  console.log(`Project: ${project_name}`);
});

// Initialize database
async function initDatabase() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Insert sample data
    await connection.execute(`
      INSERT IGNORE INTO users (name, email) VALUES 
      ('John Doe', 'john@example.com'),
      ('Jane Smith', 'jane@example.com'),
      ('Bob Johnson', 'bob@example.com')
    `);
    
    await connection.end();
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

// Initialize database on startup
setTimeout(initDatabase, 5000);
EOF

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/webapp.service << 'EOF'
[Unit]
Description=Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/webapp
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=EC2_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/webapp

# Start and enable the service
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${project_name}-${environment}-system",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "${project_name}/${environment}",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s