
#!/bin/bash
echo "Starting conversion, you must have kramdoc installed"
echo "converting all md-gfm files into asciidoc format..."
find ./ -name "*.md" -type f -exec sh -c \ 'kramdoc --format=GFM --wrap=ventilate --output={}.adoc {}' \;
