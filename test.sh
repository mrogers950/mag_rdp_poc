#!/bin/bash
./a.out 'a=1' 'a=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1' 'a=2'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1' 'b=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 or b=1' 'a=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 or b=1' 'b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 or b=1' 'b=2'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 or b=1 or b=2' 'b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 or b=1 or b=2' 'b=2'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 and b=1' 'a=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 and b=1' 'b=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 and b=1' 'a=1 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 and b=*' 'a=1 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 and b=*' 'a=1 b=2'
if [ $? -ne 0 ]; then
	exit 1
fi

./a.out 'a=1 and b=1 or b=2' 'a=1 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 and b=1 or b=2' 'a=1 b=2'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 and b=1 or b=2' 'a=1 b=3'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 and b=1 or b=2' 'b=2'
if [ $? -ne 1 ]; then
	exit 1
fi

./a.out 'a=1 or b=1 and c=1' 'a=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 or (b=1 and c=1)' 'a=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '(a=1 or b=1) and c=1' 'a=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 or b=1 and c=1' 'b=1 c=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out 'a=1 or a=2 and c=1' 'a=2 c=2'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out 'a=1 and b=1 or b=2' 'b=2'
if [ $? -ne 1 ]; then
	exit 1
fi

./a.out '(a=1 and b=1) or b=2' 'b=2'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '(a=1 and b=1) or b=2' 'a=1 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '(a=1 and b=1 and c=1)' 'a=1 b=1 c=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '(a=1 and b=1 and c=1)' 'a=1 b=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=1 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=2 c=1'
if [ $? -ne 0 ]; then
	exit 1
fi
./a.out '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=3 c=1'
if [ $? -ne 1 ]; then
	exit 1
fi
./a.out '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=2 c=2'
if [ $? -ne 1 ]; then
	exit 1
fi

./a.out '(a=)' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
./a.out '(a=1 b=1)' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
./a.out '((a=1 or b=1)' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
./a.out 'a=1 or' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
./a.out 'a or b' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
./a.out '((a=1)or b=1)' 'a=1'
if [ $? -ne 44 ]; then
	exit 1
fi
