###################################################################
exec >> $3 2>&1
printf "\n"
echo $2

TEMP=$2
TEMP=$(echo "${TEMP##*.}")
sudo -u postgres psql -d$1 -c"REINDEX INDEX $TEMP"
##################################################################
