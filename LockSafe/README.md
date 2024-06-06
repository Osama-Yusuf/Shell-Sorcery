## Welcome to LockSafe: Your Secure Shell Password Manager 🛡️

#### 🌟 Features of LockSafe

* **Session PIN Lock** 🔐: LockSafe secures your session using a PIN. Once unlocked, the session remains open until you exit, so no need to re-enter the PIN constantly.
* **Encryption** 🔒: Utilizes AES-256 encryption with PBKDF2 enhancement for your password file, ensuring top-level security.
* **Ease of Use** 🎉: Simple command-line interface for adding, retrieving, and managing passwords.
* **Clipboard Support** 📋: Easily copy passwords to your clipboard on retrieval for convenient use.
* **OS Compatibility** 💻: Custom clipboard commands for different operating systems ensure seamless user experience across platforms.
****
#### Getting Started with LockSafe 🚀

1. **Initial Setup**
    
    * Download or clone the repository.
    * Open your terminal and navigate to the repository directory.
    * Run the script with your desired PIN:
        
        ```bash
        ./setup.sh -p YOUR_PIN_HERE
        ```
        
    * This creates an encrypted file `passwords.enc`, securely storing your passwords.
2. **Using LockSafe**
    
    * Run the password manager script:
        
        ```bash
        ./pwd_mgr.sh
        ```
        
    * Follow the on-screen prompts to manage your passwords:
        
        ```text
        LockSafe Menu:
        1. Add a new password
        2. Retrieve a password
        3. List all users
        4. Quit
        Choose an option (1-4):
        ```
        

#### Developer Notes 🛠️

* For manual decryption (for testing only):
    
    ```bash
    ./setup.sh -d YOUR_PIN_HERE
    ```
    

#### Contribute 🌐

* Contributions are welcome! Fork the repository and submit pull requests to help improve LockSafe.

Feel free to start managing your passwords more securely with LockSafe today! 🌟