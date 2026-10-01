#!/bin/bash
set -e

echo "=== 1. Tạo thư mục lưu trữ mã nguồn cho Beta App và Internal App ==="
sudo mkdir -p /var/www/beta-app/html
sudo mkdir -p /var/www/internal-app/html

echo "=== 2. Phân quyền thư mục ==="
sudo chown -R $USER:$USER /var/www/beta-app/html
sudo chown -R $USER:$USER /var/www/internal-app/html
sudo chmod -R 755 /var/www

echo "=== 3. Tạo file index.html cho Beta App (Port 8080) ==="
cat << 'EOF' | sudo tee /var/www/beta-app/html/index.html > /dev/null
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beta App - Port 8080</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%); color: #f8fafc; padding: 20px; }
        .card { background: rgba(30, 41, 59, 0.7); border: 1px solid rgba(255, 255, 255, 0.1); backdrop-filter: blur(12px); border-radius: 16px; padding: 40px; max-width: 500px; width: 100%; text-align: center; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4); }
        .badge { display: inline-block; background: #3b82f6; color: #ffffff; font-size: 14px; font-weight: 600; padding: 6px 14px; border-radius: 9999px; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 1px; }
        h1 { font-size: 2.2rem; margin-bottom: 12px; color: #ffffff; }
        p { color: #94a3b8; font-size: 1rem; line-height: 1.6; margin-bottom: 24px; }
        .meta-box { background: rgba(15, 23, 42, 0.6); border-radius: 8px; padding: 16px; text-align: left; font-family: 'Courier New', Courier, monospace; font-size: 0.9rem; color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.2); }
        .meta-item { margin-bottom: 6px; }
        .meta-item:last-child { margin-bottom: 0; }
    </style>
</head>
<body>
    <div class="card">
        <span class="badge">Port 8080</span>
        <h1>Beta App</h1>
        <p>Môi trường thử nghiệm ứng dụng (Testing & Staging Environment).</p>
        <div class="meta-box">
            <div class="meta-item"><strong>Service:</strong> Beta Application</div>
            <div class="meta-item"><strong>Port:</strong> 8080</div>
            <div class="meta-item"><strong>Root:</strong> /var/www/beta-app/html</div>
            <div class="meta-item"><strong>Status:</strong> Active / Healthy</div>
        </div>
    </div>
</body>
</html>
EOF

echo "=== 4. Tạo file index.html cho Internal App (Port 8090) ==="
cat << 'EOF' | sudo tee /var/www/internal-app/html/index.html > /dev/null
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Internal App - Port 8090</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #064e3b 0%, #022c22 100%); color: #f8fafc; padding: 20px; }
        .card { background: rgba(6, 78, 59, 0.5); border: 1px solid rgba(52, 211, 153, 0.2); backdrop-filter: blur(12px); border-radius: 16px; padding: 40px; max-width: 500px; width: 100%; text-align: center; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4); }
        .badge { display: inline-block; background: #10b981; color: #064e3b; font-size: 14px; font-weight: 700; padding: 6px 14px; border-radius: 9999px; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 1px; }
        h1 { font-size: 2.2rem; margin-bottom: 12px; color: #ffffff; }
        p { color: #a7f3d0; font-size: 1rem; line-height: 1.6; margin-bottom: 24px; }
        .meta-box { background: rgba(2, 44, 34, 0.7); border-radius: 8px; padding: 16px; text-align: left; font-family: 'Courier New', Courier, monospace; font-size: 0.9rem; color: #6ee7b7; border: 1px solid rgba(16, 185, 129, 0.3); }
        .meta-item { margin-bottom: 6px; }
        .meta-item:last-child { margin-bottom: 0; }
    </style>
</head>
<body>
    <div class="card">
        <span class="badge">Port 8090</span>
        <h1>Internal App</h1>
        <p>Hệ thống thông tin và quản trị nội bộ (Internal Dashboard).</p>
        <div class="meta-box">
            <div class="meta-item"><strong>Service:</strong> Internal Information Portal</div>
            <div class="meta-item"><strong>Port:</strong> 8090</div>
            <div class="meta-item"><strong>Root:</strong> /var/www/internal-app/html</div>
            <div class="meta-item"><strong>Status:</strong> Active / Restricted Access</div>
        </div>
    </div>
</body>
</html>
EOF

echo "=== 5. Tạo cấu hình Nginx Server Blocks (/etc/nginx/sites-available/multi-port.conf) ==="
cat << 'EOF' | sudo tee /etc/nginx/sites-available/multi-port.conf > /dev/null
server {
    listen 8080;
    listen [::]:8080;

    server_name _;

    root /var/www/beta-app/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 8090;
    listen [::]:8090;

    server_name _;

    root /var/www/internal-app/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

echo "=== 6. Kích hoạt Server Blocks và kiểm tra cú pháp Nginx ==="
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/
sudo nginx -t

echo "=== 7. Khởi động lại dịch vụ Nginx ==="
sudo systemctl reload nginx || sudo systemctl restart nginx

echo "=== 8. Cấu hình tường lửa UFW mở cổng 8080 và 8090 ==="
sudo ufw allow 8080/tcp
sudo ufw allow 8090/tcp
sudo ufw reload
sudo ufw status numbered

echo "=== 9. Kiểm tra phản hồi dịch vụ qua Curl ==="
echo "--- Kiểm tra Port 8080 (Beta App) ---"
curl -I http://localhost:8080

echo "--- Kiểm tra Port 8090 (Internal App) ---"
curl -I http://localhost:8090

echo "=== HOÀN TẤT THIẾT LẬP! ==="
