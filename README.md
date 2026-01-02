# Chrome for Testing Installer

This is a simple script that will install the latestest Chrome for Testing and Chromedriver to help automative testing.
I've created this quickly for my personal use but feel free to use it in your projects. 

## Usage
```shell
install_chrome.sh
```

There's two env vars you can use
- `CREATE_SYMLINK` Tells the script to create a symlink for both chrome and chromedriver
- `PLATFORM` What plaform to setup (Supports Mac-arm64, Mac-x86, Linux64)
_Mac-arm64 is used by defualt_

Full example:
```shell
CREATE_SYMLINK=true PLATFORM="Linux86" ./install_chrome.sh
```


