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

print_image(){
    #convert image to array
    x_dim=$1
    y_dim=$2
    x_dim_print=$3
    y_dim_print=$4
    Arr=()
    for (( i=0; i<$x_dim; i++ )) do
        for (( j=0; j<$y_dim; j++ )); do
            result=`magick convert images.png -format "%[fx:int(255*p{$j,$i}.r)],%[fx:int(255*p{$j,$i}.g)],%[fx:int(255*p{$j,$i}.b)]" info:-`
            Arr+=($result)
            #echo -n "$result;" >> temp_arr_file.txt
        done
        #echo "" >> temp_arr_file.txt
    done

    #printing - chunks pixels 
    chunk_x=$x_dim
    chunk_y=$y_dim
    echo ${!Arr[@]}
}

#get_dimensions images.png

print_image 5 5
