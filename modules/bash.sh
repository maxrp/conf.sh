## bash: bashrc etc.
FILES=(bashrc bash_prompt bash_aliases)
for file in "${FILES[@]}"; do
  config_install bash/$file $file
done
