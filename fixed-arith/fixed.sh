#! /bin/bash
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
