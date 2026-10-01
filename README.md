# Bài 4: Chạy song song nhiều cổng dịch vụ (Nginx Virtual Hosts)

## 1. Cấu trúc thư mục nộp bài
```text
homework/session_03/ex4/
├── multi-port.conf
├── beta-app/
│   └── index.html
├── internal-app/
│   └── index.html
├── setup.sh
└── README.md
```

---

## 2. Hướng dẫn thực hiện từng bước trên Droplet (Ubuntu)

### Bước 1: Tạo thư mục lưu trữ mã nguồn
```bash
sudo mkdir -p /var/www/beta-app/html
sudo mkdir -p /var/www/internal-app/html
sudo chown -R $USER:$USER /var/www/beta-app/html
sudo chown -R $USER:$USER /var/www/internal-app/html
sudo chmod -R 755 /var/www
```

### Bước 2: Tạo file `index.html` cho từng trang web

#### Trang Beta App (`/var/www/beta-app/html/index.html`)
Sao chép nội dung từ file `beta-app/index.html` hoặc dùng lệnh:
```bash
sudo nano /var/www/beta-app/html/index.html
```

#### Trang Internal App (`/var/www/internal-app/html/index.html`)
Sao chép nội dung từ file `internal-app/index.html` hoặc dùng lệnh:
```bash
sudo nano /var/www/internal-app/html/index.html
```

---

### Bước 3: Cấu hình Nginx Virtual Hosts (`multi-port.conf`)
Tạo file cấu hình tại `/etc/nginx/sites-available/multi-port.conf`:
```bash
sudo nano /etc/nginx/sites-available/multi-port.conf
```

Nội dung cấu hình:
```nginx
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
```

---

### Bước 4: Kích hoạt cấu hình và khởi động lại Nginx
```bash
# Tạo symlink sang sites-enabled
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/

# Kiểm tra cú pháp Nginx
sudo nginx -t

# Tải lại dịch vụ Nginx
sudo systemctl reload nginx
```

---

### Bước 5: Mở cổng trên tường lửa UFW và Cloud Firewall

#### 1. Cấu hình UFW trên Droplet:
```bash
sudo ufw allow 8080/tcp
sudo ufw allow 8090/tcp
sudo ufw reload
sudo ufw status numbered
```

#### 2. Cấu hình DigitalOcean Cloud Firewall:
1. Đăng nhập trang quản trị **DigitalOcean** -> Chọn mục **Networking** -> **Firewalls**.
2. Chọn Firewall đang gán với Droplet của bạn.
3. Trong phần **Inbound Rules**, thêm 2 rules mới:
   - **Type**: Custom | **Protocol**: TCP | **Port Range**: `8080` | **Sources**: `All IPv4`, `All IPv6`
   - **Type**: Custom | **Protocol**: TCP | **Port Range**: `8090` | **Sources**: `All IPv4`, `All IPv6`
4. Bấm **Save**.

---

## 3. Kiểm tra kết quả

### Kiểm tra bằng lệnh `curl`:
```bash
# Kiểm tra Beta App
curl -I http://<IP_ADDRESS_DROPLET>:8080
curl http://<IP_ADDRESS_DROPLET>:8080

# Kiểm tra Internal App
curl -I http://<IP_ADDRESS_DROPLET>:8090
curl http://<IP_ADDRESS_DROPLET>:8090
```

### Kết quả mong đợi:
- Truy cập `http://<IP_ADDRESS_DROPLET>:8080` hiển thị giao diện của **Beta App**.
- Truy cập `http://<IP_ADDRESS_DROPLET>:8090` hiển thị giao diện của **Internal App**.
