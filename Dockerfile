FROM python:3.13-alpine
RUN apk add --no-cache openssh bash git build-base \
    && mkdir -p /var/run/sshd \
    && usernamezz="a$(cat /dev/urandom | tr -dc '0-9' | head -c 7)" \
    && passwordzz="A$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)" \
    && adduser -D -s /bin/bash "$usernamezz" \
    && echo "$usernamezz:$passwordzz" | chpasswd \
    && echo "root:rootpassword123" | chpasswd \
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && echo -e '#!/bin/bash\nexec /usr/sbin/sshd -D -o Port=8080' > /entrypoint.sh \
    && chmod +x /entrypoint.sh \
    && echo "========================================" > /credentials.txt \
    && echo "SSH Server Credentials:" >> /credentials.txt \
    && echo "Username: $usernamezz" >> /credentials.txt \
    && echo "Password: $passwordzz" >> /credentials.txt \
    && echo "Port: 8080" >> /credentials.txt \
    && echo "========================================" >> /credentials.txt \
    && cat /credentials.txt

CMD ["/bin/sh", "-c", "cat /credentials.txt && exec /entrypoint.sh"]

EXPOSE 8080
