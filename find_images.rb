#!/usr/bin/ruby

def image_candidates(directory_path)
  # Walk the book page images, detect images within images
  Dir.chdir(directory_path)
  Dir.mkdir("working")
  Dir.mkdir("images")
  
  Dir.glob('*').each do |file|
  
    filename = file.split("/").last.gsub(".jpg", "")
    #next if ["working","images"].include?(filename)
    
    # 1) Desaturate the image
    `convert #{file} -colorspace Gray working/#{filename}G.jpg`
  
    # 2) Contrast x 8!
    `convert working/#{filename}G.jpg -contrast -contrast -contrast -contrast -contrast -contrast -contrast -contrast working/#{filename}C.jpg`
  
    # 3) Convert image to 1px x height
    `convert working/#{filename}C.jpg -resize 1x1500! working/#{filename}V.jpg`
  
    # 4) Sharpen the image
    `convert working/#{filename}V.jpg -sharpen 0x5 working/#{filename}S.jpg`

    # 5) Heavy-handed grayscale conversion
    `convert working/#{filename}S.jpg -negate -threshold 0 -negate working/#{filename}N.jpg`

    # 6) Color list
    `convert working/#{filename}N.jpg TXT:working/#{filename}.txt`

    # 7) More than 200 black pixels in a row is an IMAGE
    begin
      File.open("working/#{filename}.txt",'r') do |file|
        @color = nil
        @count = 0
        file.each_line do |line|
          line_color = line.split(" ").last.strip
          if @color == line_color
            @count = @count + 1
            if @count > 200 && @color == "black"
              puts "IMAGE - #{filename}"
              `cp #{filename}.jpg images/#{filename}.jpg`
              break
            end
          else
            @color = line_color
            @count = 0
          end
        end
      end
    rescue
      img_count = Dir.entries("images").size
      puts "\nComplete - Found #{img_count} images"
    end
  end
end

# Find path to library directory
library_directory = ARGV[0]

# Books are each sub-directory in the library directory
Dir.chdir(library_directory)
ld = Dir.pwd
puts Dir.entries(ld).size - 2 # @TODO: need more than two entries

Dir.foreach(ld) do |book|
  if book.length > 2
    puts book
    Dir.chdir(ld + "/" + book)
    book_directory_path = Dir.pwd
    image_candidates(book_directory_path)
  end
end