## bash: bashrc etc.
for file in bashrc bash_prompt bash_aliases; do
  conf bash/$file $file
done
