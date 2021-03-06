namespace :fetch do
  desc "Pulls gifs from reddit and saves them to the database"
  task :reddit_gifs, [:category, :pages] => :environment do |t, args|
    added_count = 0
    category = (args[:category] || 'hot')
    pages = (args[:pages] || 5).to_i
    puts "fetching #{category} #{pages} page(s)"
    FetchRedditImages.new(category).fetch_images(pages) do |gif|
      begin
        bytes = gif['content-length'].to_i
        if bytes > 0
          Image.create!(
            name: gif[:title],
            original_source: gif[:url],
            bytes: bytes,
            shortcode: gif[:shortcode]
          )
          puts "add #{gif.slice(:title, :url, :shortcode)}"
          added_count += 1
        end
      rescue ActiveRecord::RecordInvalid
        puts "skip #{gif.slice(:title, :url, :shortcode)}"
      end
    end

    p "#{added_count} Image(s) were added"
  end

end
