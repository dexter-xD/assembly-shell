#!/bin/sh

set -xe

# idk why I'm even making this a variable, all the different assemblers have different syntax so I can't just swap this out
ASM=nasm
if ! [ "$(command -v $ASM)" ]; then
	echo "this project requires $ASM to be installed"
	exit 1
fi

if ! [ "$LD" ]; then
	if [ "$(command -v mold)" ]; then
		LD=mold
	elif [ "$(command -v ld)" ]; then
		LD=ld
	else
		echo "no linker found"
		exit 1
	fi
fi

rm -rf obj/ build/
mkdir obj/ build/

CFILES="$(find src/ -name "*.asm")"
OBJS=""

for f in $CFILES; do
	OBJNAME="$(echo "$f" | sed -e "s/\.asm/\.o/" -e "s/src/obj/")"
	$ASM -felf64 "$f" -o "$OBJNAME"
	OBJS="$OBJS $OBJNAME"
done

$LD $OBJS -o build/shell -s

