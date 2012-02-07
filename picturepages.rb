#!/usr/bin/ruby

# === Author ===
# * Eric Larson
# * UW-Madison Libraries

# === License ===
# * No license

# === REQUIREMENTS ===
# * ruby
# * imagemagick
# - brew install imagemagick

# 1) Set up our directory structure
# - british_flora
# - british_flora/working
# - british_flora/images

 `mkdir british_flora`
 `mkdir british_flora/working`
 `mkdir british_flora/images`

# 2) Download a book from the Internet Archive
# - Example (Color): The British flora medica, or, History of the medicinal plants of Great Britain - (34 images)
# - http://openlibrary.org/books/OL13997282M
# $> curl 'http://ia600309.us.archive.org/BookReader/BookReaderImages.php?zip=/33/items/britishfloramedi01bartuoft/britishfloramedi01bartuoft_jp2.zip&file=britishfloramedi01bartuoft_jp2/britishfloramedi01bartuoft_[0000-0482].jp2&scale=2&rotate=0' -o "file_#1.jpg"
 
 `curl 'http://ia600309.us.archive.org/BookReader/BookReaderImages.php?zip=/33/items/britishfloramedi01bartuoft/britishfloramedi01bartuoft_jp2.zip&file=britishfloramedi01bartuoft_jp2/britishfloramedi01bartuoft_[0000-0482].jp2&scale=2&rotate=0' -o "british_flora/file_#1.jpg"`

# 3) Walk the book page images, detect images within images
Dir.glob('british_flora/*').each do |file|
  
  filename = file.split("/").last.gsub(".jpg", "")
  
  # 1) Desaturate the image
  `convert #{file} -colorspace Gray british_flora/working/#{filename}G.jpg`
  
  # 2) Contrast x 8!
  `convert british_flora/working/#{filename}G.jpg -contrast -contrast -contrast -contrast -contrast -contrast -contrast -contrast british_flora/working/#{filename}C.jpg`
  
  # 3) Convert image to 1px x height
  `convert british_flora/working/#{filename}C.jpg -resize 1x1500! british_flora/working/#{filename}V.jpg`
  
  # 4) Sharpen the image
  `convert british_flora/working/#{filename}V.jpg -sharpen 0x5 british_flora/working/#{filename}S.jpg`

  # 5) Heavy-handed grayscale conversion
  `convert british_flora/working/#{filename}S.jpg -negate -threshold 0 -negate british_flora/working/#{filename}N.jpg`

  # 6) Color list
  `convert british_flora/working/#{filename}N.jpg TXT:british_flora/working/#{filename}.txt`

  # 7) More than 200 black pixels in a row is an IMAGE
  begin
    File.open("british_flora/working/#{filename}.txt",'r') do |file|
      @color = nil
      @count = 0
      file.each_line do |line|
        line_color = line.split(" ").last.strip
        if @color == line_color
          @count = @count + 1
          if @count > 200 && @color == "black"
            puts "IMAGE - #{filename}"
            `cp british_flora/#{filename}.jpg british_flora/images/#{filename}.jpg`
            break
          end
        else
          @color = line_color
          @count = 0
        end
      end
    end
  rescue
    img_count = Dir.entries("british_flora/images").size
    puts "\nComplete - Found #{img_count} images / Expected 34 images"
  end
end