#! /bin/bash
fixed_format() {
    local i d
    IFS=".," read i d <<<"$1"
    d="${d}0"
    echo "$i${d:0:2}"
}
load_sin() {
    while read -r angle value; do
        lutsincos[$angle]=$value
    done < <(awk -v PI=3.14159 -v start=0 -v end=360 '
      BEGIN {
        for(angle=start; angle<end; angle++) {
          printf "%d %d \n", angle, sin(angle*(2*PI/end))*100
        }
      }')
}
sin() { echo "${lutsincos[$(($1%360))]}" ;} 
cos() { sin $(($1+90)) ;}
v() {
    IFS=' ' read -r -a vert <<< "${V[$1]}"
    echo "${vert[$2]}"
}
l() {
    IFS=' ' read -r -a line <<< "${L[$1]}"
    echo "${line[$2]}"
}
plot() { 
    [[ $1 > 0 && $2 > 0 ]] && echo -e "\E[${2};${1}H"$3; 
}
proj() {
    echo "$(( 40+(4000*$1)/(100*($3+200)))) $(( 20+(2000*$2)/(100*($3+200))))"
}
rot () {
    cf=$(cos $ax)
    sf=$(sin $ax)
    ct=$(cos $ay)
    st=$(sin $ay)
    cp=$(cos $az)
    sp=$(sin $az)
    x=$((( $1*ct*cp/100 + $2*(sf*st*cp/10000-cf*sp/100) + $3*(sf*sp/100+cf*st*cp/10000) )/100))
    y=$((( $1*ct*sp/100 + $2*(cf*cp/100+sf*st*sp/10000) + $3*(cf*st*sp/10000-sf*cp/100) )/100))
    z=$(((-$1*st        + $2* sf*ct/100                 + $3* cf*ct/100                 )/100))
    echo "$x $y $z"
}
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
declare -a P
while true; do
    clear
    for i in ${!V[@]}; do
        plot $(proj $(rot ${V[$i]})) []
    done
    #for i in ${!V[@]}; do
    #    P[$i]=$(proj $(rot ${V[$i]}))
    #done
    #for i in ${!P[@]}; do
    #    plot ${P[$i]} []
    #done
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
