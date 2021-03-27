#returns character for a specific chunk
get_character(){
    arr=("$@")
    #echo "${arr[@]}"

    length=${#arr[@]}
    if [[ $length > 1 ]]; then
        x_len=${arr[length-1]}
        y_len=$(($length/$x_len))
        echo $x_len $y_len
        
    else
        echo "An error occured. get_character did not recieve a valid array"
    fi
}

#generates characer from avgerages of chunk
get_char(){
    avg_r=$1
    avg_b=$2
    avg_g=$3

    if [[ -z $4 ]]; then
        background="light"
    else
        background="dark"
    fi

    char_list=("@" "%" "#" "&" "=" "+" "-" ":" "," ".")

    incr_size=${$((3*255/${#char_list}))%%.*}
    
    #choose characters solely based on total screen area they occupy
    #IDEA: try non-linear scaling for magnitude
    magnitude=$avg_r+$avg_b+$avg_g

    if [[ $background -eq "dark" ]]; then
        # background is dark, so we emphasize higher magnitudes, or closer to light - (255,255,255)
       dist=$((3*255-$magnitude))
    else
        # background is light, so we emphasize lower magnitudes, or closer to dark - (0,0,0)
        dist=$(($magnitude))
    fi

    index=${$((magnitude%incr_size))%%*.}
    echo ${char_list[@]}
}

#itterate through 

print_image(){
    #convert image to array - mistake bc bash can max out, so storing line by line would be ideal
    image=$1
    x_dim=$2
    y_dim=$3
    x_dim_print=$4
    y_dim_print=$5
    Arr=()
    for (( i=0; i<$x_dim; i++ )); do
        for (( j=0; j<$y_dim; j++ )); do
            result=`magick convert $image -format "%[fx:int(255*p{$j,$i}.r)],%[fx:int(255*p{$j,$i}.g)],%[fx:int(255*p{$j,$i}.b)]" info:-`
            Arr+=($result)
        done
    done

    #calculate Chunk dimensions & overlap
    # EX) 2x5 original -> 2x2; 5%2 = 1, meaning we have one "leftover" pixel.
    # We add this extra pixel into another chunk

    index=0
    horz_offset=$x_dim%$x_dim_print
    vert_offset=$y_dim%$y_dim_print
    chunk_arr=()
    
    for (( x=0; x<$x_dim_print; x++ )); do
        row_offset=$horz_offset
        for (( y=0; y<$y_dim_print; y++ )); do
            echo "yes"
            if [[ row_offset > 0 ]]; then
                row_offset=$((offset-1))
                index=$(($index+1))
            fi
            index=$(($index+1))
        done
    done
    #echo ${!Arr[@]}
}

#get_dimensions a.gif

x_dim=225
y_dim=225
x_dim_print=16
y_dim_print=16
#Copy Here
#calculating chunk dimensions
#offset=$x_dim%$x_dim_print

#echo $(($x_dim%$x_dim_print))
#print_image 5 5

#echo `var4=1`
#arr=(1 2 3 4 5 89)
#get_character "${arr[@]}" 3

    char_list=("@" "%" "#" "&" "=" "+" "-" ":" "," ".")
    lenth=$((255/${#char_list[@]}))
    incr_size=${length%%.*}
    echo $incr_size $len $length
    echo $incr_size $len