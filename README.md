## Project Juto

A high-performance, cross-platform engine built on the P-Slice framework—a powerful combination of V-Slice and Psych Engine features. Optimized for UI fluidity, stability, and automated deployment.

### **🛠 Key Features**
P-Slice Architecture: Merges the advanced technical base of V-Slice with the modularity and ease-of-use of Psych Engine.

Native Multi-Platform Support: Robust build pipelines for Windows and Linux, utilizing custom environment fixes.

Adaptive UI Scaling: Automatic resolution and interface adjustment that handles window resizing and fullscreen natively.

Optimized Build Pipeline: Custom scripts to handle library rebuilds and metadata conflicts automatically.

### **🚀 Build Instructions**
Prerequisites
You must have Haxe and Haxelib installed, along with the specific library versions defined in Project.xml.

#### ***Windows Build***
To ensure all native components (NDLLs) are compiled without HashLink conflicts:
haxelib run lime rebuild windows -nohl --quiet
lime build windows

#### ***Linux Build***
Use the environment fix script before compiling to ensure correct library paths:

Bash
chmod +x unix.sh
./unix.sh
lime build linux


### **📁 Repository Structure**
.github/: Contains CI/CD workflows for automated multi-platform releases and testing.

art/: Dedicated directory for brand assets, including window icons and logos.

assets/: Central storage for all game data, including songs, shared media, and fonts.

source/: The core Haxe source code, handling game states, engine logic, and UI components.

Project.xml: The main configuration file managing libraries, defines, and build targets.

unix.sh: A critical utility script for setting up the Linux compilation environment.

export/: Local build output directory (ignored by Git).

### **👥 Credits**
Engine Foundation: P-Slice Team (Combining V-Slice & Psych Engine).

Base Source: Funkin' Crew (V-Slice) & Shadow Mario (Psych Engine).

Development: Project Juto Team.

**Note: Project Juto is currently in active development. Features and structure are subject to change as the engine evolves.**
