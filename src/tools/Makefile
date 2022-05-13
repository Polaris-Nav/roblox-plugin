headers:
	cpp src/headers/net.h -o src/headers/net.tmp.h
	sed '/^#/ d' < src/headers/net.tmp.h > src/inc/net.h
	rm src/headers/net.tmp.h

	cpp src/headers/string.h -o src/headers/string.tmp.h
	sed '/^#/ d' < src/headers/string.tmp.h > src/inc/string.h
	rm src/headers/string.tmp.h

	cpp src/headers/time.h -o src/headers/time.tmp.h
	sed '/^#/ d' < src/headers/time.tmp.h > src/inc/time.h
	rm src/headers/time.tmp.h