CXX = g++
OBJS	= polysum.o polynomial.o
SOURCE	= polysum.cpp polynomial.cpp
HEADER	= polysum.h
OPT = -O3
OUT	= polysum
LFLAGS	 = -lgmpxx -lgmp

all: polysum

polysum: $(OBJS)
	$(CXX) -o $@ $^ $(OPT) $(LFLAGS) $(OPT)

%.o: %.cpp $(HEADER)
	$(CXX) -c -o $@ $< $(LFLAGS) $(OPT)

clean:
	rm -f $(OBJS) $(OUT)
