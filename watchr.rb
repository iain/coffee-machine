watch "src/.*\.coffee" do |m|
  system "thor", "coffee:compile", "--growl", m[0].to_s
end

watch 'public/.*' do |m|
  project_name = File.basename(File.expand_path(m[0]).gsub(%r"/public/.*", ''))
  system "autorefresh", project_name
end
