# Intro
This haphazardly written shell script fetches files from samftp server.

Files are seleted though the fzf program and then fetched with yt-dlp.

To select multiple files (up to eight- this can be changed by configuring
        the --multi flag in fzfCmd() in the script) hold shift and press tab, finally press enter.

Press Ctrl+C couple of times to quit during a session.

# Dependency's
    1. yt-dlp
    2. fzf
    3. awk
    4. curl
    5. sed
    6. grep
    7. xmllint from libxml2

No. 3-7 are usually preinstalled in gnu/linux systems, I think.

# Screenshot
![screenshot](screenshot.jpg)


Inspired by ytfzf by pystardust.
