#! /bin/bash

#get image file & check if we are able to process it
check_image() {
    image_file=$1;

    if [[ -z $image_file ]]; then
        echo "Please supply a valid file name"
    fi

    if [[ ! -e $image_file ]]; then 
        echo "file does not exist"
    elif [[ ! -r $image_file || ! -f $image_file ]]; then 
        echo "file is not readable"
    fi

    #get list of supported file extensions (ie. png)
    if [[ -e supportedList.txt && -r supportedList.txt ]]; then
        #loading list
        file_extn_list=(`cat "supportedList.txt"`)
        echo ${file_extn_list[@]}
        
        #check if file extension is part of supported list
        flag=0
        file_type=${image_file##*.}; file_type=${file_type,,}
        #echo $file_type

        #FIX HERE!!
        for i in "${file_extn_list[@]}"; do
            if [[ ${i%%//n} =~ $file_type ]]; then
                flag=1
            fi
            echo ${i%%/n}
                    echo $file_type
        done
        if [[ count -eq 0 ]]; then
            echo "file type not supported"
        fi
    else
        echo "List of supported files can not be found, so your file can not be verified. Would you like to continue? [y/n]:"
        read ans
        ans=${ans,,}
        if [[ $ans == 'n' ]]; then
            echo "Exiting..."
            exit
        fi
    fi
}

get_dimensions() {
    image=$1
    lower=$((${#image}+1))
    upper=$((${#image}+2))
    echo $lower $upper
    result=`magick identify ${image}`
    #result is in form of [file name] [file type] [dimensions]. 
    #File type is max 4 char & dimensions max 4-4, totalling 13 chars 
    result=${result:lower:upper}
    echo $result
}

image=$1
check_image $image
get_dimensions $