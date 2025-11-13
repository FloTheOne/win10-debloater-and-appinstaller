Windows Configuration Automation Tool

-Overview

This application automates the process of installing and configuring technologies on Windows operating systems.
It allows users to define complete system presets — including user profiles, directory structures, applications, and performance optimizations — and automatically applies them through generated scripts.

The app can also sync these presets to Firebase, making it possible to reuse or deploy configurations across multiple devices.


Modules:

-GUI (PyQt) – defines the full configuration preset.
-JSON Config – stores user-defined settings and preferences.
-Script Generator – creates .cmd and .ps1 scripts for automation.
-Firebase Integration – uploads or retrieves presets from the cloud.



Tech Stack

-Component:	Technology

-Interface:	PyQt (Python)

-Language:	Python 3.19

-Package Manager:	Chocolatey

-Scripting:	CMD / PowerShell

-Config Format:	JSON

-Cloud Sync:	Firebase ( Database / Firestore)

-Registry Tweaks:	Windows Registry (Regedit)



Usage

1. Launch the application.
  
2. Create a new preset and add user profiles.
   
3. Define directories, software, and optimization options.
   
4. Generate the configuration script (.cmd or .ps1).
   
5. Optionally upload your preset to Firebase for cloud sync.
    
6. Run the script on any Windows machine (as Administrator).


<img width="1408" height="824" alt="image" src="https://github.com/user-attachments/assets/9ed50d01-3072-44af-aa50-9b901507103b" />

