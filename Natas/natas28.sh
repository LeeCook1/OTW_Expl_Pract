
SITE="http://natas28.natas.labs.overthewire.org/"
#SITE="127.0.0.1:2222"
USER=""
PWORD=""
USER_AGENT="Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8"
FILE_DICT="dictionary_natas28.txt"
TMP="tmp.txt";

declare -A char_encrypt_arr;
get_encrypt()
{
	headers=$(curl -u "$USER":"$PWORD" -A "$USER_AGENT" "$SITE" --data-binary query="$(echo -e "$1")" -s -D - -o /dev/null);
	#urlencode_base64_query=$(echo $headers | grep "query=" | awk -F'query=' '{print $2}');
	#urlbase64decoded_query=$(python urldecode.py $urlencode_base64_query | xxd -p |tr -d '\n');
	#formatted_query=$( echo $urlbase64decoded_query | sed 's/.\{32\}/&\n/g' > $TMP);
	#line=$(sed '4q;d' $TMP);
	echo "$headers";	
}

get_start() {
	
	if [ -e $FILE_DICT ] && [ $(wc -l $FILE_DICT | cut -d' ' -f1 ) -gt 0 ]
	then
		read -r -a left_off < $FILE_DICT;
		start=${left_off[0]};
		found=${left_off[1]};
		echo $start $found;
	else
		echo 25 " ";
	fi
}
#	if [ ! -e $FILE_DICT ]
#	then 
#		> $FILE_DICT
#	else
#		line_count=$(wc -l $FILE_DICT | cut -d' ' -f1);
#	fi
#
#	if [[ $(head -n1 $FILE_DICT | tr -d ' ')  =~ ^[0-9]+$ ]]
#	then
#		sed -i '1d' $FILE_DICT;
#		echo "deleted"
#	fi

make_table() 
{
	line_count=0;
	char_encrypt_arr=();
	
	linenum=0;
	numchars=$1;
	found="$2";

	if [ $line_count  -gt 1 ]
	then
		echo "Building from file: $FILE_DICT"

		read -r -a cur_char < $FILE_DICT
		while read -r -a lines
		do
			char_encrypt_arr+=( [${lines[0]}]=$linenum );
			linenum=$(( $linenum+1 ))

			echo "updating: char $linenum, key ${lines[0]}"
		done < $FILE_DICT
		echo "Finish building from file"
	fi
	
	for ((i=$linenum; i < 256; i++ ))
	do
		charhex=$(printf '%02x' $i);
		query=$(python -c "print 'A'*$numchars");
		query+="$found"
		query+="\x$charhex";
		line=$(get_encrypt "$query");
		char_encrypt_arr+=( [$line]=$i );
		
		echo "Saving: '$query' $line $i"
	
		echo $line $i >> $FILE_DICT ;
	done

	echo "###########################################"
}

natas28_get_encrypt()
{
	recent=$(get_start);
	start=$(echo "$recent" | cut -d' ' -f1 | tr -d ' ');
	found="$(echo "$recent" | cut -d' ' -f2 | tr -d ' ')";

	echo "Starting with $start A's and found $found"
	for (( count=$start; count > 0 ; count-- ))
	do
		echo "Initializing Table using $count A's..."
		make_table $count "$found";
		
		query="$(python -c "print 'A'*$count")";
		line=$(get_encrypt $query);

		echo "Checking: $count A's: $query $line"	
		if [ ${char_encrypt_arr[$line]+xyz} ]
		then
			char_hex=$(printf '%02x' ${char_encrypt_arr[$line]} );
			found="$found%$char_hex"
			echo "Found char: $char_hex, $query$found"

			echo $(( $count-1 )) "$found" > $FILE_DICT;
		else
			echo "Can't find char for position $(( $count+1 ))";
			exit 1;
		fi
	done
}

get_encrypt "$1"
#natas28_get_encrypt
