
run:
	hugo server

new-post:
	@read -p "Enter the folder name for the new post (slug): " slug; \
	if [ -n "$$slug" ]; then \
		CONTENT_ITEM_PATH_REL_TO_CONTENT_DIR="posts/$$slug"; \
		FULL_ITEM_PATH_FROM_PROJECT_ROOT="content/$$CONTENT_ITEM_PATH_REL_TO_CONTENT_DIR"; \
		if hugo new "$$CONTENT_ITEM_PATH_REL_TO_CONTENT_DIR/index.md"; then \
			mkdir -p "$$FULL_ITEM_PATH_FROM_PROJECT_ROOT/image"; \
			echo "Leaf Bundle structure (index.md and image/ directory) created at '$$FULL_ITEM_PATH_FROM_PROJECT_ROOT'"; \
		else \
			echo "Failed to create '$$FULL_ITEM_PATH_FROM_PROJECT_ROOT/index.md'. Please check if the slug already exists, if Hugo is correctly configured, or if another error occurred."; \
		fi; \
	else \
		echo "No slug entered. Operation cancelled."; \
	fi