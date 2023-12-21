#!/usr/bin/env bash
#created by lelouch29
#no. of seasons must be less or equal to 10, otherwise shows blank list
#Who watches a show with more than 10 seasons? (not a bug, I swear)

declare urls=(
"englishMovies                 http://172.16.50.7/SAM-FTP-7/English%20Movies/ "
"englishMovies1080p            http://172.16.50.14/SAM-FTP-14/English%20Movies%20%281080p%29/ "
"animationMovies               http://172.16.50.14/SAM-FTP-14/Animation%20Movies/ "
"animationMovies1080p          http://172.16.50.14/SAM-FTP-14/Animation%20Movies%20%281080p%29/ "
"tvSeries                      http://172.16.50.12/SAM-FTP-12/TV-WEB-Series/ "
"anime                         http://172.16.50.9/SAM-FTP-9/Anime%20%26%20Cartoon%20TV%20Series/ ")
fzfCmd () {
    fzf --cycle --border='sharp' --border-label='∈ samfzf ∋' --border-label-pos=0 --padding=1 --margin=2 --multi=8 --prompt='●▶ ' --marker='+'
}

specialChars="$|–|—|_|.|+|!|*|‘|(|)|,|à|á|â|ã|ä|ç|è|é|ê|ë|ì|í|î|ï|ñ|ò|ó|ô|õ|ö|š|ù|ú|û|ü|ý|ÿ|ž"
unnstrings='\(modern browsers\|powered by SamOnline\|Parent Directory\)'
choice=$(printf '%s\n' "${urls[@]}" | fzfCmd | awk -F '[[:space:]][[:space:]]+' '{print $2}' )

for i in 1 2 3 4
do
    #remove & because its a special character
    page=$(curl -s $choice | sed 's/&/and/g')
    #search for .mkv</a>
    #if grep finds video it returns 0 exit code, if not, urls are directories and we
    #gotta go deeper
    exitCode=$(echo $page | grep -E '.mkv<|.avi<|.mp4<|.m4v<' ; echo $?)
    if [ "$exitCode" == 1 ]; then

        inPage=$(echo $page | xmllint --html --xpath "//a/text()" -)

        #some brute force regex specific to SAMFTP
        # the ".*2" in the last regex is for samftps urls ending like: ...../season%202, the first 2 is common to urls of inside of "Seasons"
        selected=$(echo "$inPage" | sed "/$unnstrings$/d" | fzfCmd | sed  -e 's/and//g' -e "s/[$specialChars]/.*/g" -e 's/♥/E2%99%A5.*/' -e 's/♦/E2%99%A6.*/' -e 's/★/E2%98%85.*/' -e 's/ /.*2.*/g')

        linkList=$(echo $page | xmllint --html -xpath "//a/@href" -  | sed -e 's/href=//' -e 's/"//g')
        link=$(echo "$linkList" | grep -E "$selected")

        #if some unicode breaks the sed
        if [ $? == 1 ]; then
            fixSelect=$(echo "$selected" | sed 's/[^a-zA-Z]/.*/g')
            link=$(echo "$linkList" | grep -E "$fixSelect")
        fi

        baseURL=$(echo "$choice" | sed 's/\/SAM-FTP.*$//')
        fullURL=$(echo $baseURL$link | sed 's/ //g')
        choice=$fullURL
    else
        inPage=$(echo $page | xmllint --html --xpath "//a/text()" -)
        selected=$(echo "$inPage" | sed "/$unnstrings$/d" | fzfCmd | sed -e 's/ /.*/g' -e 's/and//g' -e "s/[$specialChars]/.*/g")
        linkList=$(echo $page | xmllint --html -xpath "//a/@href" -  | sed -e 's/href=//' -e 's/"//g')
        link=$(echo "$linkList" | grep -E "$selected")

        if [ $? == 1 ]; then
            fixSelect=$(echo "$selected" | sed 's/[^a-zA-Z]/.*/g')
            link=$(echo "$linkList" | grep -E "$fixSelect")
        fi

        baseURL=$(echo "$choice" | sed 's/\/SAM-FTP.*$//')
        line=1

        for i in $link
        do
            fullURL=$(echo $baseURL$i | sed 's/ //g')

            fileExtn=$(echo $selected | awk -F\* {'print $NF'})
            fileName=$(echo "$selected" | sed -n "${line}p" | sed -e 's/[.*]//g' -e 's/\(mkv$\|avi$\|mp4$\|m4v$\)//').$fileExtn

            yt-dlp $fullURL -o "$fileName"
            line=$((line+1))
        done
        break
    fi
done
