old_string="carrot"
new_string="foods"

for file in *"$old_string"*; do
    # Use parameter expansion to create the new filename
    newfile="${file/$old_string/$new_string}"
    
    # Check if the filename actually changes to avoid errors
    if [[ "$file" != "$newfile" ]]; then
        mv -v "$file" "$newfile"
    fi
done