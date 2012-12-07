echo "File: " $1
file=$1
awk < $file '{ 
if (a[$1]++ == 0) print $0; 
}' "$@"
