
nothing:
	@echo "No default target."

fix-eol:
	find . -type f -exec grep -l '\r' {} \; | \
		xargs perl -i -p -e 's/\r\n/\n/g; s/\r/\n/g;' 