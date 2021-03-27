#! /bin/bash

#get image file & check if we are able to process it
check_image() {
    image_file=$1;

    if [[ -z $image_file ]]; then
        echo "Please supply a valid file name" >&2
    fi

    if [[ ! -e $image_file ]]; then 
        echo "file does not exist" >&2
    elif [[ ! -r $image_file || ! -f $image_file ]]; then 
        echo "file is not readable" >&2
    fi

    #get list of supported file extensions (ie. png)
    if [[ -e supportedList.txt && -r supportedList.txt ]]; then
        #loading list
        file_extn_list=(`cat "supportedList.txt"`)
        #echo ${file_extn_list[@]}
        
        #check if file extension is part of supported list
        flag=0
        file_type=${image_file##*.}; file_type=${file_type,,}
        #echo $file_type

        #FIX HERE!!
        for i in ${file_extn_list[@]}; do
            if [[ $i =~ $file_type ]]; then
                flag=1
            fi
            #echo ${i%%/n}
            #echo $file_type
        done
        if [[ count -eq 0 ]]; then
            echo "file type not supported" >&2
        fi
    else
        echo "List of supported files can not be found, so your file can not be verified. Would you like to continue? [y/n]:"
        read ans
        ans=${ans,,}
        if [[ $ans == 'n' ]]; then
            exit
        fi
    fi
}

get_dimensions() {
    image=$1
    result=`magick identify $image`
    
    #result is in form of [file name] [file type] [dimensions]. 
    #File type is max 4 char & dimensions max 4-4, totalling 13 chars max.
    lower=$((${#image}+4))
    upper=13
    result=${result:lower:upper}

    #removing 
    echo ${result% *}
}

#generates characer for chunk
get_char(){
    avg_r=$1
    avg_b=$2
    avg_g=$3

    char_list=("@" "%" "#" "&" "=" "+" "-" ":" "," "." " ")
    incr_length=$((3*255/${#char_list[@]}))
    
    #choose characters solely based on total screen area they occupy
    #IDEA: try non-linear scaling for magnitude
    magnitude=$(($avg_r+$avg_b+$avg_g))

    if [[ $4 -eq 1 ]]; then
        # background is dark, so we emphasize higher magnitudes, or closer to light - (255,255,255)
        dist=$(($magnitude))
    else
        # background is light, so we emphasize lower magnitudes, or closer to dark - (0,0,0)
        dist=$((3*255-$magnitude))
    fi
    index=$((dist/incr_length))
    echo ${char_list[index]}
}

#turns string of rgb values in form "25,25,25" to array of 3 numbers
get_rgb(){
    rgbs=()
    str=$@

    first=${str%%,*}
    #cut out 1st and 3rd elements
    second=${str:$((${#first}+1)):${#str}}; second=${second%%,*}
    third=${str##*,}
    rgbs+=($first)
    rgbs+=($second)
    rgbs+=($third)
    echo ${rgbs[@]}
}

print_image(){
    #convert image to array
    x_dim=$1
    y_dim=$2
    x_dim_print=$3
    y_dim_print=$4
    background=$5
    Arr=()
    #Each row is x_dim_print long & Each column is y_dim_print long
    for (( i=0; i<$x_dim; i++ )); do
        for (( j=0; j<$y_dim; j++ )); do
            result=`magick convert images.png -format "%[fx:int(255*p{$j,$i}.r)],%[fx:int(255*p{$j,$i}.g)],%[fx:int(255*p{$j,$i}.b)]" info:-`
            Arr+=($result)
        done
    done

    #printing - chunks pixels 
    chunk_x=$x_dim
    chunk_y=$y_dim
    echo ${!Arr[@]}
}

#Paramater order: [file_name] -specify_dimensions [x_length] [y_length] -background [dark/white]
#parameters: 
# defaults: to_x; to_y calculated 
#Defaults 
image=$1
#check_image $image

#-----------------------------
#Testing stuff
#coords=()
coords=$(get_rgb "2,658,256")
echo ${coords[@]}
#get_dimensions $
#check if dimensions are > to_x & to_y
#if true, 