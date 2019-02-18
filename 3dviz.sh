#! /bin/bash
## q and s to rotate the cube ##
fixed_format() {
    local i d
    IFS=".," read i d <<<"$1"
    d="${d}0000"
    echo "$i${d:0:4}"
}
fixed_print() {
    var=$1
    if [[ $var = -* ]]; then
        sign="-"
        var="${var:1}"
    else
        sign=""
    fi
    int=$((10#$var/10000))
    dec="0000$((10#$var-(int*10000)))"
    echo "$sign$int.${dec: -4}"
}
fixed_int_print () {
    var=$1
    if [[ $var = -* ]]; then
        sign="-"
        var="${var:1}"
    else
        sign=""
    fi
    int=$((10#$var/10000))
    echo "$sign$int"
}
div() { 
    local a b sa sb
    a=$1
    if [[ $a = -* ]]; then
        sa="-"
        a="${a:1}"
    else
        sa=""
    fi
    b=$2
    if [[ $b = -* ]]; then
        sb="-"
        b="${b:1}"
    else
        sb=""
    fi
    #echo "a=$a"
    #echo "b=$b"
    echo "$(( ($sa$((10#$a))*10000) / $sb$((10#$b)) ))"; 
}
mul() { 
    local a b sa sb
    a=$1
    if [[ $a = -* ]]; then
        sa="-"
        a="${a:1}"
    else
        sa=""
    fi
    b=$2
    if [[ $b = -* ]]; then
        sb="-"
        b="${b:1}"
    else
        sb=""
    fi
    echo "$(( $sa$((10#$a))* $sb$((10#$b))/10000))"; 
}
add() { 
    echo "$(($((10#$1))+$((10#$2))))"; 
}
sub() { 
    echo "$(($((10#$1))-$((10#$2))))"; 
}
load_sin() {
    while read -r angle value; do
        lutsincos[$angle]=$(fixed_format $value)
    done < <(awk -v PI=3.14159 -v start=0 -v end=360 '
      BEGIN {
        for(angle=start; angle<end; angle++) {
          printf "%d %.4f \n", angle, sin(angle*(2*PI/end))
        }
      }')
}
sin() { echo "${lutsincos[$(($1%360))]}" ;} # echoes a sin, use as : $(sin angle) with angle the angle you wanna retrieve !!WARNING!! these belong to [0;360] and output ints in [0;100], with period 360
cos() { sin $(($1+90)) ;} # echoes a cos, use as : $(cos angle) with angle the angle you wanna retrieve !!WARNING!! these belong to [0;360] and output ints in [0;100], with period 360
v() {  # use as $(v idx dim) with idx the index of the vertex, dim the dimension to access
    IFS=' ' read -r -a vert <<< "${V[$1]}"
    echo "${vert[$2]}"
} # Example use: echo "V[$idx]=($(v idx 0),$(v idx 1),$(v idx 2))"
l() {  # use as $(l idx vert) with idx the index of the line, vert(in [0;1]) the first or second array
    IFS=' ' read -r -a line <<< "${L[$1]}"
    echo "${line[$2]}"
} # Example use: echo "l[$idx]=[$(l idx 0),$(v idx 1)]"
plot() { 
    [[ $1 > 0 && $2 > 0 ]] && echo -e "\E[${1};${2}H"$3; 
} # plot row col char, row col ints describing the coordinates where to draw, char the char to draw
proj() {
    echo "$((20+$(fixed_int_print $(mul 200000 $(div $2 $(add $3 20000)))))) $((40+$(fixed_int_print $(mul 400000 $(div $1 $(add $3 20000))))))"
}
rot () {
    echo "$(add $(mul $1 $(cos $ay)) $(mul $3 $(mul -10000 $(sin $ay)))) $2 $(add $(mul $1 $(sin $ay)) $(mul $3 $(cos $ay)))"
}
#echo "$(mul 10000 20000)"

declare -a lutsincos # stores a LUT for cosine and sine functions
load_sin # loads the LUT with sine values normalized as: sine([0;255])=[0;255], period is 256
for i in ${!lutsincos[@]}; do echo ${lutsincos[$i]}; done
declare -a V # stores all the vertices in the format: "v:index:x y x" with v a char indicating it is a vertex, index an int(>=0), x y x ints
declare -a L # stores all the lines linking vertices in the format: "l:index: v1 v2" with l a char indicating it is a line, index an int(>=0), v1 v2 indices of 2 existing vertices
file=${1--}
while read -r line; do
    IFS=':' read -r -a args <<< "$line"
    case ${args[0]} in
    	v) # if it is a vertex
            IFS=' ' read -r -a vert <<< "${args[2]}"
            for v in vert; do
                V[${args[1]}]="$(fixed_format ${vert[0]}) $(fixed_format ${vert[1]}) $(fixed_format ${vert[2]})"
            done ;;
        l) # if it is a line
            L[${args[1]}]="${args[2]}";;
        *) echo "Error loading $1 : Cannot read line \"$line\""
    esac
done < <(cat -- "$file")
clear # now we start talking, once everything is loaded!
### cube plotting section ###
ax=0 # angle around the x axis, rotating on the yz plane [0..360]
ay=0 # angle around the y axis, rotating on the xz plane [0..360]
az=0 # angle around the z axis, rotating on the xy plane [0..360]
while true; do
    clear
    for i in ${!V[@]}; do
        #echo ${V[$i]}
        #proj ${V[$i]}
        #plot $(proj ${V[$i]}) $i
        plot $(proj $(rot ${V[$i]})) $i
    done
    read -n1 key
    case $key in 
        q) ((ay+=5)) ;;
        s) ((ay-=5)) ;;
        a) ((az-=5)) ;;
        z) ((az+=5)) ;;
        d) ((ax+=5)) ;;
        e) ((ax-=5)) ;;
        ²) exit ;;
    esac
done
