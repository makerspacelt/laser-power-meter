BAUD=460800
PORT=/dev/ttyUSB0
ESPTOOL=esptool
NODEMCU_TOOL=nodemcu-tool
FW=fw/nodemcu_integer_mkspc-lasermeter.bin

SCRIPTS=$(wildcard src/*.lua)


help:
	@echo

flash:
	$(ESPTOOL) --port=$(PORT) --baud $(BAUD) write_flash 0x00000 $(FW)

upload-scripts:
	$(NODEMCU_TOOL) --silent upload -m -c src/ds18b20.lua src/http_handler.lua

upload-index:
	$(NODEMCU_TOOL) --silent upload src/index.html

upload-init:
	$(NODEMCU_TOOL) --silent upload -m src/init.lua

upload: upload-index upload-init upload-scripts

reset:
	$(NODEMCU_TOOL) --silent reset

terminal:
	$(NODEMCU_TOOL) --silent terminal

fsinfo:
	$(NODEMCU_TOOL) fsinfo
