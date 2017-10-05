import sys
import urllib
import base64
import requests

SITE="http://natas28.natas.labs.overthewire.org/"
USER=""
PWORD=""
USER_AGENT="Mozilla/5.0 (X11; U; Linux x86_64; de; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8"

FILE_DICT="dictionary_natas28.txt"
TMP="tmp.txt";

BLOCK_SIZE = 16
BLOCK_OFFSET = 10

CHARS_PER_BYTE = 2

HIDDEN_RIGHT_COUNT = 29

KEY_SECT_OFFSET = BLOCK_SIZE * 4
KEY_SECT_CHAR_OFFSET = KEY_SECT_OFFSET * CHARS_PER_BYTE

def get_enc_str(query):
    enc = send_query(query)
    b64dec = base64.b64decode(enc).encode('hex')
    return b64dec[KEY_SECT_CHAR_OFFSET: KEY_SECT_CHAR_OFFSET + BLOCK_SIZE]

def send_query(query):
    url = SITE + "?query=" + query
    r = requests.get(url,headers={'User-Agent':USER_AGENT}, auth=(USER,PWORD))
    encrypted_url = urllib.unquote(r.url.split('=')[1]).decode('utf8')
    return encrypted_url

def make_keys(base, found_str):
    byte_keys = {}
    base_url_enc = urllib.quote(base+found_str) 
    print "Starting Keys for base:", base
    for i in xrange(0, 256):
        new_block_str= base_url_enc + "%%%02x" % (i)
        enc_str = get_enc_str(new_block_str)
        val = [i]
        if enc_str in byte_keys.keys():
            prev = byte_keys[enc_str]
            val += prev
    
        #print "Byte:","%%%02x"%(i),"\nStr:",new_block_str,"\nEnc:",enc_str,"\nVal:",val,"\n"
        #print "Encrpted Section:",enc_str,"Val:", val
        sys.stdout.write("Key making progess: %d/255\r" % (i) )
        sys.stdout.flush()

        byte_keys.update( {enc_str:val} )

    return byte_keys

def find_byte(base, found_str):
    choice = 0
    byte_keys = make_keys(base, found_str)
    print "Keys Completed"

    base_enc_url = urllib.quote(base)
    cipher_str = get_enc_str(base_enc_url)
    byte_found = byte_keys[cipher_str]
    found_len = len(byte_found)
    if found_len > 1:
        print "Found duplicate keys"
        for i in xrange(0, found_len):
            print "\t",i,byte_found[i]
        
        choice = raw_input("Pick 1:")
        assert (choice >= 0 and choice < found_len) 

    byte_found = byte_found[choice]
    print "Byte Found:", hex(byte_found)

    assert isinstance(byte_found, int), ""
    return chr(byte_found)

def main():
    found_str = ""
    base_str = 'A'*BLOCK_OFFSET + 'B'*16 + 'C'*15
    
    for i in xrange(0,  HIDDEN_RIGHT_COUNT):
        byte = find_byte(base_str, found_str)
        base_str = base_str[:-1]
        found_str += byte
        
        print i, urllib.quote(base_str)

    return 0

if '__main__' == __name__:
    main()
