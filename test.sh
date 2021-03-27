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

#itterate through 

print_image(){
    #convert image to array - mistake bc bash can max out, so storing line by line would be ideal
    image=$1
    x_dim=$2
    y_dim=$3
    chunk_x=$4
    chunk_y=$5
    background=$6
    
    #calculate Chunk dimensions & overlap
    # EX) 2x5 original -> 2x2; 5%2 = 1, meaning we have one "leftover" pixel.
    # We add this extra pixel into another chunk

    index=0
    horz_offset=$x_dim%$chunk_x
    vert_offset=$y_dim%$chunk_y
    chunk_count=$((chunk_x*chunk_y))
    echo $chunk_count
    #goes through each chunk - indexes={i*} where i is the ith chunnk
    for (( i=0; i<$chunk_count; i++ )); do
        for (( j=0; j<$y_dim; j++ )); do
            result=`magick convert $image -format "%[fx:int(255*p{$j,$i}.r)],%[fx:int(255*p{$j,$i}.g)],%[fx:int(255*p{$j,$i}.b)]" info:-`
            
            #parse results for rgb values
            first=${result%%,*}
            #cut out 1st and 3rd elements
            second=${result:$((${#first}+1)):${#result}}; second=${second%%,*}
            third=${result##*,}
            echo $first $second $third
        done
    done

    #calculate Chunk dimensions & overlap
    # EX) 2x5 original -> 2x2; 5%2 = 1, meaning we have one "leftover" pixel.
    # We add this extra pixel into another chunk

    index=0
    horz_offset=$x_dim%$chunk_x
    vert_offset=$y_dim%$chunk_y
    chunk_arr=()
    
    for (( x=0; x<$chunk_x; x++ )); do
        row_offset=$horz_offset
        for (( y=0; y<$chunk_y; y++ )); do
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
#char_list=("@" "%" "#" "&" "=" "+" "-" ":" "," ".")
#incr_length=$((3*255/${#char_list[@]}))
#echo $incr_length
#get_char 0 0 0 1
print_image images.png 10 10 1 1