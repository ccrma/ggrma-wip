for file in *.png; do
    echo "Resizing $file"
    ffmpeg -i "$file" -vf scale=-1:1280 -y "${file%.png}_temp.png"
    mv "${file%.png}_temp.png" "$file"
done