# Security Journal

This files provides you goods and bads habits according to your infrastructure. 
Each infrastructure poses unique risks and must be secured.  

### 1) Classical installation : Fanless behind your Box.

**Characteristics:**
- No static IP or DNS resolution by default
- No DMZ or port forwarding unless manually configured
- Possibly weak Wi-Fi or LAN security  

**Risks:**
- Port Exposure: Only ports 80 and 443 should be open. Watch to have the right configuration.
- No Hardware Firewalls: If your network is very weak, an attacker could go unnoticed.
- DdoS Vector: Easily targeted with DoS due to weak residential upload bandwidth.

**Recommended Actions:**
- Use a local firewall like ufw to restrict ports.
- Monitor network traffic with tools like iftop or vnstat.
- Limit access to apXtri UI using client-side certificates or VPNs.
- Your can check your open ports with netstat.
- You can ban IPs with fail2ban

### 2) VPS (ex : OVHcloud).  

**Characteristics:**
- Hosted on OVHcloud's virtual server infrastructure (KVM-based VPS)
- Comes with a public static IPv4 and possibly IPv6
- Often protected by OVH's basic anti-DDoS layer by default
- Full root access provided to the user
- Network is directly exposed to the internet unless manually firewalled
- Typically used for remote deployments, staging environments, or lightweight production APIs

**Risks:**
- OVH provides to you a configuration with a protection anti Ddos 
- All trafics is redirected
- if you are victim of a Ddos attack you can use apxtri to relauch your service

**Recommended Actions:**  
- Configure your firewall of OVH
- Limits your ways to authenticated to your machine
- Configure a backup


### 3) Client-owned Box :

**Characteristics:**  
- Depending on your hardware you may lack resources (CPU, RAM)
- You should have more ports opened than 80 and 443
- Your network configuration is totally controlled by you

**Risks:**  
- The client may expose ports (80/443 or custom APIs) without proper firewall rules or monitoring
- Device may run outdated or unpatched software, increasing attack surface
- Insecure or default credentials on the box may allow attackers to pivot into apXtri
- If OpenPGP keys are managed or stored locally and not securely, full authentication compromise is possible
- Local storage may be unencrypted or shared, increasing the chance of key or token leakage
- No central update mechanism — clients may not apply security updates to apXtri or its dependencies
- Logins or commands may be sent over insecure channels (HTTP, LAN), making traffic interceptable by internal actors or malware
- If compromised, attacker may gain visibility on both LAN and exposed routes, bridging internal and external networks 

**Recommended Actions:**
- Verify all your credentials (strong password policies, disable unused accounts)
- Connect via a VPN
- Set up alerts redirected to log 

### Key recommendations : 
| Area                  | Recommendation                                      |
|-----------------------|-----------------------------------------------------|
| **Network Security**  | Use VPNs or tunneling for admin access              |
| **Authentication**    | Enforce strict PGP signature validation             |
| **User Privileges**   | Limit `sudo` use post-setup                         |
| **Web Exposure**      | Avoid unnecessary port forwarding                   |
| **Key Management**    | Use expiry and rotate public/private keys regularly |
| **Audit Logging**     | Enable and monitor system + Caddy logs              |
| **Update Strategy**   | Lock to known-good git commits, avoid auto-updates  |
