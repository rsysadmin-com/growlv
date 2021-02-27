# growlv
Small script to make easy growing a LV

```
Usage: growlv.sh size+units lv

input units:
                b|B is bytes, 
                s|S is sectors of 512 bytes, 
                k|K is kilobytes, 
                m|M is megabytes, 
                g|G is gigabytes, 
                t|T is terabytes,
                p|P is petabytes, 
                e|E is exabytes

example: 
        ./growlv.sh 200G root
          this will add +200 GB to the root LV
          
          ./growlv.sh 10G var
          this will add +10 GB to the var LV
          
        If no LV is given, the root-lv will be used as default.

         ./growlv.sh 50G
         this will add +50 GB to the root LV

```