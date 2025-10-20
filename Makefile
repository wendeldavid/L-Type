ZIP_NAME=L-Type.love
FOLDERS=libs assets animations
LUA_FILES=$(wildcard *.lua)

package: clean
	zip -r $(ZIP_NAME) $(LUA_FILES) $(FOLDERS)

clean:
	@echo "Cleaning up..."
	@rm -f $(ZIP_NAME)

deploy: package
	@echo "Deploying in R36s Love2D folder..."
	@sudo mkdir -p /mnt/love

	@sudo mount /dev/sda3 /mnt/love

	@cp L-Type.love /mnt/love/love2d

	@sudo umount /mnt/love

	@echo "=========================== IMPORTANT ==========================="
	@echo "Rememeber to unmount from Ubuntu"
