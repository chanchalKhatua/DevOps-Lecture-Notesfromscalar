## Public Key Infrastructure (PKI)

### 🧸 PKI for a 5-Year-Old
Imagine you want to send a secret message to your friend without anyone else reading it.

You and your friend both have special mailboxes.

Each mailbox has two keys:

One key is public (anyone can have it).

One key is private (only you can keep it safe and hidden).

Here’s how it works:

You get your friend’s public key.

You use it to lock the message (encrypt).

Only your friend can unlock it with their private key.

If your friend wants to reply, they do the same thing with your public key.

And to make sure no one is pretending to be your friend, there's a trusted teacher (Certificate Authority) who checks and confirms whose mailbox is real.

### 🧠 PKI Grown-up Version – Step-by-Step
1. Generate Key Pairs
Each user/device generates a public-private key pair.

Private key stays secret.

Public key is shared with the world.

2. Request Certificate
The user sends their public key to a Certificate Authority (CA).

This includes some identity info (like name, org, domain, etc.).

The request is a CSR (Certificate Signing Request).

3. CA Verifies Identity
The CA checks that the requester is legit (could be manual or automated).

Think: passport check.

4. CA Issues Certificate
If everything checks out, CA signs the user’s public key with its own private key.

This creates a digital certificate.

Now anyone can trust the public key—because it’s signed by the CA.

5. User Shares Certificate
The user shares their certificate, not their private key.

Others use it to:

Encrypt data for the user.

Verify signatures from the user.

6. Secure Communication
Encrypted data can only be decrypted with the user’s private key.

Signatures can be verified using the sender’s public key.

![PKI - visual selection](https://github.com/user-attachments/assets/155f1711-f257-4d09-a925-4b7839292ee0)

![ChatGPT Image Apr 17, 2025, 05_39_10 PM](https://github.com/user-attachments/assets/8ed48ce4-f1f9-4fa0-bf63-3e4585e44060)

### Useful Commands:

```
To read the encrypted cert file in text format:

openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -text -noout

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout
```