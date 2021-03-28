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

    horz_offset=$x_dim%$chunk_x
    vert_offset=$y_dim%$chunk_y
    chunk_count=$((chunk_x*chunk_y))
    echo $chunk_count
    x_pix_per_chunk=$(($x_dim / $chunk_x))
    y_pix_per_chunk=$(($y_dim / $chunk_y))
    #itterates through each chunk 
    current_row=0
    echo "|" >> debug.txt
    for (( chunk=0; chunk<$chunk_count; chunk++ )); do
        #accumulators for chunks
        n=0
        r_total=0; g_total=0; b_total=0
        #row=0
        #calculates number of x chunks and y chunks traveled to find new starting index
        #y_chunks=$(($chunk/$horz_chunk_count)); index=$(($x_dim*$y_chunks)) # might need to do x_dim-1
        #x_chunks=$(($chunk%$horz_chunk_count)); index=$(($index+$x_chunks*$chunk_x))

        y_index=$(($chunk/$horz_chunk_count)); y_index=$(($chunk_y*$y_index))
        y_max=$(($y_dim/$chunk_y))
        x_max=$(($x_dim/$chunk_x))
        for (( j=0; j<$y_max; j++ )); do
            x_index=$(($chunk%$horz_chunk_count))
            for (( i=0; i<$x_max; i++ )); do
                result=`magick convert $image -format "%[fx:int(255*p{$x_index,$y_index}.r)],%[fx:int(255*p{$x_index,$y_index}.g)],%[fx:int(255*p{$x_index,$y_index}.b)]" info:-`
                #parse results for rgb values
                r=${result%%,*}
                #echo $x_index $y_index
                #cut out 1st and 3rd elements respectively
                g=${result:$((${#r}+1)):${#result}}; g=${g%%,*}
                b=${result##*,}
                #echo $first $second $third
                r_total=$(($r_total+$r))
                g_total=$(($g_total+$g))
                b_total=$(($b_total+$b))
                n=$(($n+1))
                x_index=$(($x_index+1))
            done
            y_index=$(($y_index+1))
        done
            #calculating averages
            r_avg=$(($r_total/$n)); b_avg=$(($b_total/$n)); g_avg=$(($g_total/$n))
            #reset 
            char=$(get_char $r_avg $b_avg $g_avg)
            echo -n $char
            
            chunk_row=$(($chunk/$horz_chunk_count))
            if [[ $current_row < $current_row ]]; then
            # write to next line
            echo ""
            row=$(($current_row+1))
            echo $n $r_total >&2
            fi
    done

    #calculate Chunk dimensions & overlap
    # EX) 2x5 original -> 2x2; 5%2 = 1, meaning we have one "leftover" pixel.
    # We add this extra pixel into another chunk
}


#get_dimensions a.gif

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
#print_image2 images1.png 50 50 25 25 1
#get_char $1 $2 $3 1

