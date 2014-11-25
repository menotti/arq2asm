CC=cc
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=filtro_linux.c
OBJECTS=$(SOURCES:.c=.o)
TESTS=in/*.pnm
EXEC=./filtro_linux 

all: $(SOURCES) $(EXEC) test 

$(EXEC): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

test:
	for file in $(TESTS); do $(EXEC) <$$file >$${file/in/out}; done

clean: 
	rm -rf *.o $(EXEC)
