CC=cc -m32
CFLAGS=-c -Wall
LDFLAGS=-m32
SOURCES=filtro_unix.c
OBJECTS=$(SOURCES:.c=.o)
TESTS=in/*.pnm
EXEC=./filtro_unix

all: $(SOURCES) $(EXEC) test 

$(EXEC): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

test:
	for file in $(TESTS); do $(EXEC) <$$file >$${file/in/out}; done

clean: 
	rm -rf *.o $(EXEC)
