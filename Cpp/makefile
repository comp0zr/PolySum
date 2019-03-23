CXX = g++
OBJS	= polysum.o
SOURCE	= polysum.cpp
HEADER	= 
OUT	= polysum
LFLAGS	 = -lgmpxx -lgmp

all: polysum

polysum: $(OBJS)
	$(CXX) -o $@ $^ $(LFLAGS)

%.o: %.c $(HEADER)
	$(CXX) -c -o $@ $< $(LFLAGS)

clean:
	rm -f $(OBJS) $(OUT)
