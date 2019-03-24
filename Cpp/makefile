CXX = g++
OBJS	= polysum.o polynomial.o
SOURCE	= polysum.cpp polynomial.cpp
HEADER	= polysum.h
OUT	= polysum
LFLAGS	 = -lgmpxx -lgmp

all: polysum

polysum: $(OBJS)
	$(CXX) -o $@ $^ $(LFLAGS)

%.o: %.c $(HEADER)
	$(CXX) -c -o $@ $< $(LFLAGS)

clean:
	rm -f $(OBJS) $(OUT)
