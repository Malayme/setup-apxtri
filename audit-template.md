# Audit template for apXtri
This file is for any pentester who want to audit apXtri. It presents you quickly the project and guides as a template to how audit apXtri.  
***
Firstly, you will need to ask you some sommary questions.  
## Reminder :  
- **Tested Perimeter ?** 
- **Environment ?**
- **Application features ?**
- **Do I need other informations ?**

Then you will pentest the application according to your answers to the previous questions and all questions that you **<u>will</u>** have.  
***
Now you will see what categories that you need to audit if you audit the whole application.
## Tested perimeter :
- Ubuntu server/desktop
- user gestion
- /opt, /var/lib, /var/log
- Cloned git repos
- Which paquets ? (apt)  

## Environment :
- Need to be sudo
- Production environment
- Node.js, Express.js server

## Features :
- User creation
- curl, git
- Creation of linux repos
- chown
***
Now you will see what type of table we can have : 

| Potential Vulnerabilities             | Attack Scenario                                                                                 | Severity         | Impact                                               |
|---------------------------------------|-------------------------------------------------------------------------------------------------|------------------|------------------------------------------------------|
| `apxtri` user add to sudo group       | An attacker compromising this account gains root privileges.                                    | High             | Full system control                                  |
| Non authenticated git repo            | Man-in-the-Middle attack or repository modification                                             | Moderate to high | Malicious code executed during installation          |
| Creating files in `/opt`, `/var`...   | Use of these paths by a third-party service, risk of collision                                  | Low              | System instability or takeover by hijacking          |
| No depedencies validation             | A package compromised via APT or an outdated version with known vulnerabilities                 | Moderate to high | Vulnerability to escalation or arbitrary execution   |
| No secured logs                       | No error tracking during installation                                                           | Moderate         | More difficult to diagnose, increased risk           |
| No git fingerprint validation         | No validation of the downloaded code                                                            | Moderate         | Execution of unverified code                         |
| Usage of `sudo` non restricted        | If the script is modified, `sudo` can be abused without restrictions                            | Moderate to high | Takeover via arbitrary commands                      |
| Dynamic IP / Firewall                 | The home router (box) blocks Caddy or Express server, making the API unreachable or unreliable. | High             | Service disruption, loss of updates, sync failures.  |
| Unsecured Git clone                   | Man-in-the-middle attack on `git clone` via HTTP or untrusted source.                           | Medium           | Malicious code deployed during installation.         |
| Weak server-side GPG validation       | Invalid/fake signatures accepted, or expired keys, or replaying an old signed message.          | Medium to High   | Authentication bypass via forged OpenPGP signatures. |
| Unsanitized timestamp in signature    | Signature only checks `alias_timestamp` without temporal constraints; vulnerable to replay.     | Medium           | Replay attacks, re-use of valid signed requests.     |
| Directory permissions / Caddy access  | Insecure permissions allow Caddy (or other processes) to modify backend files.                  | Medium to High   | Malicious web code execution, secret leakage.        |
| Overuse of CPU / lack of resources    | Fanless device suffers from performance issues under heavy cryptographic load.                  | Low to Medium    | Local denial-of-service or performance degradation.  |
| No auto-update mechanism              | No scheduled updates; outdated dependencies or unpatched vulnerabilities.                       | Medium           | Long-term exposure to known vulnerabilities.         |
| Compromised or spoofed GPG public key | Attacker submits a malicious key, system accepts it, bypassing trust model.                     | Low              | Identity impersonation, unauthorized access.         |
