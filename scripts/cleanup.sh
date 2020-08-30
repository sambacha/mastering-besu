#!/bim/bash
for file in *.md.adoc; do
    mv "$file" "$(basename "$file" .md.adoc).adoc"
done