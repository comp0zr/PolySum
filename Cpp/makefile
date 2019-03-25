CXX = g++
OBJS	= polysum.o polynomial.o
SOURCE	= polysum.cpp polynomial.cpp
HEADER	= polysum.h
OPT = -O2
OUT	= polysum
LFLAGS	 = -lgmpxx -lgmp

all: polysum

polysum: $(OBJS)
	$(CXX) -o $@ $^ $(OPT) $(LFLAGS)

%.o: %.c $(HEADER)
	$(CXX) -c -o $@ $< $(OPT) $(LFLAGS)

clean:
	rm -f $(OBJS) $(OUT)
