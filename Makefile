.DEFAULT_GOAL=portable

ZIP_NAME=L-Type.love
FOLDERS=libs assets
LUA_FILES=$(wildcard *.lua)
BUILD_TYPE_FILE=build.type

portable: clean
	@echo "Packaging portable version..."
	@echo "portable" >> ${BUILD_TYPE_FILE}
	make package

pc: clean
	@echo "Packaging PC version..."
	@echo "pc" >> ${BUILD_TYPE_FILE}
	make package

package:
	zip -r $(ZIP_NAME) $(LUA_FILES) ${BUILD_TYPE_FILE} $(FOLDERS)

clean:
	@echo "Cleaning up..."
	@rm build.type
	@rm -f $(ZIP_NAME)
