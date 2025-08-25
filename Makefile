# Makefile para empacotar arquivos .lua e pastas específicas


ZIP_NAME=L-Type.love
FOLDERS=libs assets
LUA_FILES=$(wildcard *.lua)

package:
	zip -r $(ZIP_NAME) $(LUA_FILES) $(FOLDERS)

clean:
	rm -f $(ZIP_NAME)
