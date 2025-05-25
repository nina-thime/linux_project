upstream backend {
    server 192.168.1.10:80;  # IP Master
    server 192.168.1.11:80;   # IP Slave
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
