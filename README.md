# Chrome for Testing Installer

This is a simple script that will install the latestest Chrome for Testing and Chromedriver to help automative testing.
I've created this quickly for my personal use but feel free to use it in your projects. 

## Usage
```shell
install_chrome.sh
```

There's two env vars you can use
- `CREATE_SYMLINK`: Tells the script to create a symlink for both chrome and chromedriver
- `PLATFORM`: What plaform to setup (Currently supports Mac-arm64, Mac-x86, Linux64) _Mac-arm64 is used by default_
- `FORCE_REINSTALL`: Deletes current files and reinstalls both chrome and chromedriver 

Full example:
```shell
CREATE_SYMLINK=true PLATFORM="Linux86" FORCE_REINSTALL=true ./install_chrome.sh
```
