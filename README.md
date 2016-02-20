# [Temporal.pw]

[Temporal.pw] provides temporary secure storage for passwords so you can safely transmit them over insecure channels like E-Mail, Instant Messaging, SMS, etc.
  - Passwords are only ever stored after being encrypted with random 16-byte AES encryption key.
  - The AES decryption keys are *never* stored on the server side, each unique temporary URL holds the actual decription key required to decrypt the password.
  - The encrypted passwords are immediately *permanently* deleted from the database whenever any one of these conditions occur:
    - The user clicks the "Delete now" link.
    - The unique URL is visited after the expiration time.
    - The unique URL is visited more times than the user allowed.
  - Expired encrypted passwords are never visible to anyone after their expiration time and are permanently deleted from the database within 1 hour of their expiration.
  - You can optionally restrict unique temporary password URLs so that they're only accessible from your same IP address (useful for sending passwords securely to someone in the same network).
  - Hosted entirely on Google App Engine servers.
  - Only ~150 lines of python code.
  - Uses standard [PyCrypto] library for encryption.


[Temporal.pw]: <https://temporal.pw/>
[PyCrypto]: https://www.dlitz.net/software/pycrypto/
