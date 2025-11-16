Windows Configuration Automation Tool

-Overview

This application automates the process of installing and configuring technologies on Windows operating systems.
It allows users to define complete system presets — including user Windows 10 profiles, directory structures, auto instaall applications, and performance optimizations (delete Microsoft's automatically installed apps, turn off telemetry, disable adds and more) — and automatically applies them through generated scripts.

The app can also sync these presets to Firebase, making it possible to reuse or deploy configurations across multiple devices.


Modules:

-GUI (PyQt) – defines the full configuration preset.

-JSON Config – stores user-defined settings and preferences.

-Script Generator – creates .cmd and .ps1 scripts for automation.

-Firebase Integration – uploads or retrieves presets from the cloud.



Tech Stack:

-Component:	Technology

-Interface:	PyQt (Python)

-Language:	Python 3.19

-Package Manager:	Chocolatey

-Scripting:	CMD / PowerShell

-Config Format:	JSON

-Cloud Sync:	Firebase ( Database / Firestore)

-Registry Tweaks:	Windows Registry (Regedit)



Usage:

1. Launch the application.
  
2. Create a new preset and add user profiles.
   
3. Define directories, software, and optimization options.
   
4. Generate the configuration script (.cmd or .ps1).
   
5. Optionally upload your preset to Firebase for cloud sync.
    
6. Run the script on any Windows machine (as Administrator).


<img width="1408" height="824" alt="image" src="https://github.com/user-attachments/assets/9ed50d01-3072-44af-aa50-9b901507103b" />
<img width="690" height="521" alt="image" src="https://github.com/user-attachments/assets/5925ccc2-debc-4d32-8d20-07599fa05fdb" />
<img width="1218" height="478" alt="image" src="https://github.com/user-attachments/assets/86cf18f1-3f10-466c-8fe5-4961a9c3ab73" />
<img width="1249" height="502" alt="image" src="https://github.com/user-attachments/assets/be6ef1ff-0c7d-4a00-91a4-42c0763004ac" />
<img width="1330" height="762" alt="image" src="https://github.com/user-attachments/assets/3ecec6df-7240-4bd5-834f-87f50ce91af2" />





