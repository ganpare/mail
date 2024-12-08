FROM python:3.9-slim

WORKDIR /app

COPY send_mail.py ./

RUN apt-get update && apt-get install -y \
    iputils-ping \
    telnet \
    dnsutils

CMD ["sh", "-c", "python3 send_mail.py && tail -f /dev/null"]