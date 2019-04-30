CXX = g++
OBJS	= equation_iterator.o polysum.o polynomial.o linear_system.o
SOURCE	= equation_iterator.cpp polysum.cpp polynomial.cpp linear_system.cpp
HEADER	= polysum.h
OPT = -O3
GCCFLAGS = -fopenmp
OUT	= polysum
LFLAGS	 = -lgmpxx -lgmp

all: polysum

polysum: $(OBJS)
	$(CXX) -o $@ $^ $(OPT) $(LFLAGS) $(GCCFLAGS) $(OPT)

%.o: %.cpp $(HEADER)
	$(CXX) -c -o $@ $< $(LFLAGS) $(GCCFLAGS) $(OPT)

clean:
	rm -f $(OBJS) $(OUT)
