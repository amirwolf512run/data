FROM rust:alpine

# نصب پکیج‌های مورد نیاز و سرویس OpenSSH
RUN apk add --no-cache openssh bash git build-base \
    && mkdir -p /var/run/sshd \
    # تنظیم رمز عبور دسترسی root (می‌توانید تغییر دهید)
    && echo "root:rootpassword123" | chpasswd \
    # فعال‌سازی ورود مستقیم کاربر root و احراز هویت با پسورد
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    # تولید کلیدهای اصلی SSH
    && ssh-keygen -A \
    # اسکریپت استارت‌آپ برای اجرای SSHD روی پورت 8080
    && echo -e '#!/bin/bash\nexec /usr/sbin/sshd -D -o Port=8080' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
