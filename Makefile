ZIP_NAME=L-Type.love
FOLDERS=libs assets
LUA_FILES=$(wildcard *.lua)

package: clean
	zip -r $(ZIP_NAME) $(LUA_FILES) $(FOLDERS)

clean:
	@echo "Cleaning up..."
	@rm -f $(ZIP_NAME)
