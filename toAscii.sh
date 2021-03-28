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
        if [[ flag -eq 0 ]]; then
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

    char_list=("@" "%" "#" "&" "=" "+" "-" ":" "," ".")

    incr_length=$((3*255/${#char_list[@]}))
    
    #choose characters solely based on total screen area they occupy
    #IDEA: try non-linear scaling for magnitude
    magnitude=$(($avg_r+$avg_b+$avg_g))

    if [[ $4 -eq 1 ]]; then
        # background is light, so we emphasize lower magnitudes, or closer to dark - (0,0,0)
        dist=$((magnitude))
    else
        # background is dark, so we emphasize higher magnitudes, or closer to light - (255,255,255)
        dist=$((3*255-magnitude))
    fi
    index=$((dist/incr_length))
    if [[ $index > 0 ]]; then
        index=$((index-1))
    fi
    #echo $index >&2
    #echo $1 $2 $3 $incr_length >&2
    echo "${char_list[index]} "
}

print_image(){
    image=$1
    x_dim=$2
    y_dim=$3
    chunk_x=$4
    chunk_y=$5
    background=$6
    output_type=$7

    x_pix_per_chunk=$((x_dim/chunk_x))
    y_pix_per_chunk=$((y_dim/chunk_y))

    for (( ch_y=0; ch_y<chunk_y; ch_y++ )); do
        #accumulators for chunks
        #bounds for chunk itteration 
        init_y=$((ch_y*y_pix_per_chunk))
        y_max=$((init_y+y_pix_per_chunk))

        #stores each line of characters
        line=()
        for (( ch_x=0; ch_x<chunk_x; ch_x++ )) do
            init_x=$((ch_x*x_pix_per_chunk))
            x_max=$((init_x+x_pix_per_chunk))
            n=0
            r_total=0; g_total=0; b_total=0
        
            #itterate through pixels chunks  
            for (( y=$init_y; y<$y_max; y++)); do
                for (( x=$init_x; x<$x_max; x++)) do
                    result=`magick convert $image -format "%[fx:int(255*p{$x,$y}.r)],%[fx:int(255*p{$x,$y}.g)],%[fx:int(255*p{$x,$y}.b)]" info:-`
                    #parse rgb values from output
                    r=${result%%,*}
                    g=${result:$((${#r}+1)):${#result}}; g=${g%%,*}
                    b=${result##*,}
                    
                    #adding to accumulators
                    n=$((n+1))
                    r_total=$(($r_total+$r)); g_total=$(($g_total+$g)); b_total=$(($b_total+$b))
                done
            done
            #calculate avgs and determine character
            r_avg=$(($r_total/$n)); b_avg=$(($b_total/$n)); g_avg=$(($g_total/$n))
            line+=$(get_char $r_avg $b_avg $g_avg $background)
            #echo -n $char >> debug.txt
            #echo $n $r_total >&2
        done
        #create new row
        echo -n "|" 
        echo -n ${line[@]}
        echo -n "|" 
        echo "" 
    done
}

#Paramater order: [file_name] -background [dark/white] -specify_dimensions [x_length] [y_length] -output_type [stdout or textfile]
#Defaults: to_x; to_y auto-calculated; background: dark; output-type: textfile

image=$1
check_image $image

dimensions=$(get_dimensions $image)
#parsing output
d1=${dimensions%%x*}
d2=${dimensions##*x}

if [[ -z $3 ]]; then
    d1_new=$(($d1/4))
else 
    d1_new=$3
fi

if [[ -z $4 ]]; then 
    d2_new=$(($d1/4))
else 
    d2_new=$4
fi

echo $image $d1 $d2 $d1_new $d2_new
print_image $image $d1 $d2 $d1_new $d2_new $2
#-----------------------------
#Testing stuff

#check if dimensions are > to_x & to_y
#if true, 