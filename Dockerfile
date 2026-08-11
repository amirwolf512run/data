FROM python:3.13-alpine
# نصب پکیج‌های مورد نیاز و سرویس OpenSSH
RUN apk add --no-cache openssh bash git build-base \
    && mkdir -p /var/run/sshd \
    # تولید نام کاربری و رمز عبور تصادفی
    && usernamezz="a$(cat /dev/urandom | tr -dc '0-9' | head -c 7)" \
    && passwordzz="A$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)" \
    # ایجاد کاربر با نام تصادفی
    && adduser -D -s /bin/bash "$usernamezz" \
    && echo "$usernamezz:$passwordzz" | chpasswd \
    # تنظیم رمز عبور دسترسی root (می‌توانید تغییر دهید)
    && echo "root:rootpassword123" | chpasswd \
    # فعال‌سازی ورود مستقیم کاربر root و احراز هویت با پسورد
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    # تولید کلیدهای اصلی SSH
    && ssh-keygen -A \
    # اسکریپت استارت‌آپ برای اجرای SSHD روی پورت 8080
    && echo -e '#!/bin/bash\nexec /usr/sbin/sshd -D -o Port=8080' > /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    # ذخیره اطلاعات کاربر در فایل برای نمایش در زمان اجرا
    && echo "========================================" > /credentials.txt \
    && echo "SSH Server Credentials:" >> /credentials.txt \
    && echo "Username: $usernamezz" >> /credentials.txt \
    && echo "Password: $passwordzz" >> /credentials.txt \
    && echo "Port: 8080" >> /credentials.txt \
    && echo "========================================" >> /credentials.txt \
    && cat /credentials.txt

# نمایش اطلاعات هنگام اجرای کانتینر
CMD ["/bin/sh", "-c", "cat /credentials.txt && exec /entrypoint.sh"]

EXPOSE 8080
