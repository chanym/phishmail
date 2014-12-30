#!/usr/bin/ruby

require 'mechanize'

print "\n**	Bing Scrape Email Harvester in ruby						**\n"
print "**	Original script in python was created by  H@ck1tHu7ch (Justin Hutchens)		**\n"
print "**	https://github.com/hack1thu7ch/PhishBait/blob/master/Bing_Scraper.py		**\n"
print "**	Have seek Mr. Hutchens permission before I recode it in ruby			**\n\n"

if (ARGV.length != 3) || (!ARGV[0].to_i.between?(1,7))
	puts "Usage - ./bing_scraper.rb [Format num] [suffix] [output_file]"
	puts "FORMATS:"
	puts "1 - [first].[last]@[suffix]"
	puts "2 - [last].[first]@[suffix]"
	puts "3 - [first][last]@[suffix]"
	puts "4 - [last][first]@[suffix]"
	puts "5 - [first initial][last]@[suffix]"
	puts "6 - [first]_[last]@[suffix]\n"
	puts "7 - [last]_[first]@[suffix]\n"
	puts "Example - ./bing_scraper.rb 1 company.com output.txt"
	puts "Example will create email list in the form of john.smith@company.com\n\n"
	exit
end

format = ARGV[0].to_i
suffix = ARGV[1].to_s.downcase
filename = ARGV[2].to_s
file = File.open(filename,'w')
all_emails = []

def formatting(names, suffix, format) #create email format base on the chosen format
	emails = []
	names.each do |x|
		x = x.to_s
		emails.push((x.split[0] + '.' + (x.split[1] || '')).downcase + '@' + suffix) if format == 1  
		emails.push(((x.split[1] || '') + '.' + x.split[0]).downcase + '@' + suffix) if format == 2
		emails.push((x.split[0] + (x.split[1] || '')).downcase + '@' + suffix) if format == 3
		emails.push(((x.split[1] || '') + x.split[0]).downcase + '@' + suffix) if format == 4
		emails.push((x.split[0][0] + (x.split[1] || '')).downcase + '@' + suffix) if format == 5
		emails.push((x.split[0] + '_' + (x.split[1] || '')).downcase + '@' + suffix) if format == 6
		emails.push(((x.split[1] || '') + '_' + x.split[0]).downcase + '@' + suffix) if format == 7
	end
	return emails 
end

print "Enter the company name: "
company = $stdin.gets.chomp
company = company.sub(' ','%20')

agent = Mechanize.new
agent.robots = 'disable'
page = agent.get('http://www.bing.com/search?q=(site%3A%22www.linkedin.com%2Fin%2F%22%20OR%20site%3A%22www.linkedin.com%2Fpub%2F%22)%20%26%26%20(NOT%20site%3A%22www.linkedin.com%2Fpub%2Fdir%2F%22)%20%26%26%20%22'+company+'%22&qs=n&form=QBRE&pq=(site%3A%22www.linkedin.com%2Fin%2F%22%20or%20site%3A%22www.linkedin.com%2Fpub%2F%22)%20%26%26%20(not%20site%3A%22www.linkedin.com%2Fpub%2Fdir%2F%22)%20%26%26%20%22'+company+'%22')   #Search queries to bing to query linkedIn site for user entered company name

loop do     
	names = []
	page.search('h2').each {|h2| names.push(h2.inner_text.split('|')[0].rstrip) if h2.inner_text.include? "LinkedIn"}   #Getting all the names found within h2 tag with LinkedIn mention within

	email_list = formatting(names, suffix, format)

	email_list.each {|x| puts x}
	all_emails.push(email_list) 
	
	if link = page.link_with(:text => "Next")  # will loop until no more Next hyperlink found
		page = link.click
	else
		break
	end
end

print "...\n"
puts "Sorting, removing duplicates and writing to file #{ARGV[2]}....."
all_emails.flatten.sort!.uniq!.each {|x| file.puts(x)}   #sort and uniq all emails and write to file
puts "Done!" 
file.close()








