#!/bin/bash
rm -rf *.md
rm -rf *.JSON
rm -rf *.MDUMMY
echo Downloading Report number $1
wget -q --show-progress "https://api.github.com/repos/israpps/Open-PS2-Loader-Compatibility-list/issues/$1" -O REPORT.JSON
dos2unix REPORT.JSON
echo Processing data...
jq -r '.body' REPORT.JSON > BODY.MDUMMY
awk '/^### */{ close(out); out=$2".md" } out!=""{print > out}' BODY.MDUMMY

echo MDs
ls *md
echo END MDs

for a in *.md
do
sed -i '/^###/d' $a
sed  -i '/^\s*$/d' $a
sed  -i '/\/n$/d;' $a
done

declare TESTER=$(jq ".user.login" REPORT.JSON)
declare ELF=$(head -n 1 Game.md)
declare PLAYABLE=$(head -n 1 gameplay.md)
declare TITLE=$(head -n 1 title.md)
declare DEVICE=$(head -n 1 device.md)
declare OPL=$(head -n 1 OPL.md)
declare CONSOLE_MODEL=$(head -n 1 Console.md)
declare FORMAT=$(head -n 1 format.md)
declare MEDIA=$(head -n 1 media.md)

if grep -q "_No response_" Compatibility.md
then
	echo - No compatibility modes provided
else
	declare COMPAT_MODES=$(paste -s -d ' ' Compatibility.md)
fi

if grep -q "_No response_" comments.md
then
	echo - No comments provided
else
	declare COMMENTS=$(paste -s -d ' ' comments.md)
fi

sed -ni '/\[X\]/p' features.md
for A in VMC PADEMU PADMACRO IGR GSM
do
	if grep -q "$A" features.md
	then
	declare $A=YES
	fi
done
echo "--------------------{ SUMMARY }--------------------"
echo TESTER  		- $TESTER -
echo TITLE  		- $TITLE -
echo ELF 			- $ELF -
echo DEVICE 		- $DEVICE -
echo FORMAT 		- $FORMAT -
echo MEDIA 			- $MEDIA -
echo OPL VERSION	- $OPL -
echo ---
echo VMC 			- $VMC -
echo PADEMU 		- $PADEMU -
echo PADMACRO 		- $PADMACRO -
echo IGR 			- $IGR -
echo GSM 			- $GSM -
echo ---
echo COMPAT_MODES 	- $COMPAT_MODES -
echo COMMENTS 		- $COMMENTS -

if [[ "$TITLE" =~ ^[a-z]|[A-Z].* ]]; then
FSTCHAR=${TITLE:0:1}
FSTCHAR=${FSTCHAR^^}
else
FSTCHAR=NUMBERED
fi
echo game goes into folder $FSTCHAR

FILETARGET="../List/$FSTCHAR/$ELF.md"
echo file path $FILETARGET
if [ -f $FILETARGET ]
then
	echo "$FILETARGET Exists, skipping creation"
else
	echo "$FILETARGET doesnt exist, creating new file with game title as heading"
	echo "# $TITLE">$FILETARGET
	echo "## __$ELF__">>$FILETARGET
	echo "">>$FILETARGET
	echo appending table header liquid macro
	cat heading.TEMPLATE >> $FILETARGET
fi

echo "| $MEDIA | $FORMAT | $OPL | $DEVICE | $COMPAT_MODES | $VMC | $IGR | $PADEMU | $PLAYABLE | $TESTER | $CONSOLE_MODEL | $COMMENTS ">>$FILETARGET

