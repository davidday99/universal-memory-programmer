PROJECT = main
DEV = /dev/ttyACM0
FLASHER = lm4flash
SRCS = $(wildcard src/*.c) \
		   $(wildcard src/*.s)
OBJ = obj/
OBJS = $(addprefix $(OBJ), $(filter-out %.c, $(notdir $(SRCS:.s=.o))) $(filter-out %.s, $(notdir $(SRCS:.c=.o))))
INC = -I. -Iinc/
LD_SCRIPT = TM4C123GH6PM.ld

CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld 
DEBUGGER = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
RM = rm -rf
MKDIR = @mkdir -p $(@D)

CFLAGS = -ggdb3 -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -nostartfiles -ffreestanding
CFLAGS += -mfloat-abi=hard -MD -std=c99 -Wextra -Wall -Wno-missing-braces
DEPFLAGS = -MT $@ -MMD -MP

all: bin/$(PROJECT).elf

$(OBJ)%.o: src/%.c          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)
	
$(OBJ)%.o: src/%.s          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)

bin/$(PROJECT).elf: $(OBJS) 
	$(MKDIR)           
	$(CC) -o $@ $^ $(CFLAGS) $(DEPFLAGS) -Wl,-T$(LD_SCRIPT) -Wl,-eResetISR -Llib -Wl,-l:libdriver.a
	$(OBJCOPY) -O binary $@ bin/$(PROJECT).bin 
	ctags -R src inc

flash:
	$(FLASHER) -S $(DEV) bin/$(PROJECT).bin

debug:
	$(DEBUGGER) --tui bin/$(PROJECT).elf -ex "target remote :3333" -ex "monitor reset halt"

-include $(OBJS:.o=.d)

clean:
	-$(RM) obj
	-$(RM) bin

