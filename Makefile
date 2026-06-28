CXX = g++
CXXFLAGS = -std=c++20 -Wall -Wextra -I./include -I./server -I./utils

SRCDIR = src
OBJDIR = obj
BINDIR = .
EXECUTABLE = $(BINDIR)/UTrello
MEDIA_PATH = ./files/

VPATH = src:server:utils

SOURCES = $(wildcard src/*.cpp) $(wildcard server/*.cpp) $(wildcard utils/*.cpp)

OBJECTS = $(patsubst %.cpp, $(OBJDIR)/%.o, $(notdir $(SOURCES)))

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@ -I$(MEDIA_PATH)

clean:
	rm -rf $(OBJDIR) $(EXECUTABLE)
