import smtplib
import os

# デバッグログ
print("Starting email sending script...")

# SMTPサーバ情報
smtp_server = os.environ.get('SMTP_SERVER', 'smtp.example.local')
smtp_port = 25
print(f"Connecting to SMTP server: {smtp_server}:{smtp_port}")

# メール送信設定
from_email = "test@example.local"
to_email = "test@example.local"
subject = "Test Mail from App Server"
body = "This is a test email sent from app-server via dockerized SMTP server."

# メールフォーマットにFrom:やTo:ヘッダを追加
message = f"From: {from_email}\nTo: {to_email}\nSubject: {subject}\n\n{body}"


try:
    # SMTPサーバ接続とメール送信
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        print("Connected to SMTP server.")
        server.sendmail(from_email, to_email, message)
        print("Email sent successfully.")
except Exception as e:
    print("Error while sending email:", e)
