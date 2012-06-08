# The program takes a username and number of latest tweets
# to be considered. It then reads the latest 'n' tweets for user
# and extracts all the words from them.
# The program finally sorts the words in order of frequency of occurrence and prints them.
#
# Author:: Himani Ahuja
# Email:: himani.ahuja@sv.cmu.edu
#

require 'rubygems'
require 'httparty'

class TweetWords
	include HTTParty
	format :json
    
    # This method takes the parameters of the userName and number of tweets to be parsed
	# and calls the methods to get the tweets and extract words from them. It then sorts
	# the words in decreasing order of frequencies and prints the word list.
    
	def self.topWords(userName, maximumNumberOfTweets)
    
		tweets = topTweets(userName, maximumNumberOfTweets)
		wordSet = findTopWords(tweets)

		puts "Top words in descending order of frequency: "

		wordSet.sort_by { |word, count| count }.reverse.each do |wrd|
		puts "#{wrd[0]}"

		end
		return ' '
	end


	# This method gets top 'n' tweets from Twitter as requested by the user.
	# Twitter API only returns 20 most recent statuses posted by the user. Thus, this method
	# invokes the request multiple times until the requested number is reached.

	def self.topTweets(screen_name, maxNumber)

		count = 0
		id = 0
		response = Array.new(1000)

		begin

			responseFromTwitter = getTweets(screen_name, id)

			#responseFromTwitter.parsed_response.each_with_index do |elem, index|
			responseFromTwitter.parsed_response.each do |elem|

				response[count] = elem['text']
				count = count + 1

				id = Integer(elem['id']) - 1   # storing max_id to be used in subsequent calls

				if count >=maxNumber
					break
				end
			end
		end while count < maxNumber

		return response
	end


	# This method gets top tweets from Twitter by making an API call via HTTParty.
	# The parameters passed are the 'screen_name' which is screen name of the user
	# for whom to return results for and 'max_id' which returns results with an ID
	# less than (that is, older than) or equal to the specified ID. The method returns
	# the top 20 tweets as 'responseTweets'.

	def self.getTweets(screen_name, max=0)

		parameters = {:screen_name => screen_name }

		if max > 0
			parameters[:max_id] = max
		end

		responseTweets = get('http://api.twitter.com/1/statuses/user_timeline.json', :query => parameters )
		return responseTweets

	end


	# This method splits the tweet strings into words, counts each word's frequency and returns the word set.

	def self.findTopWords(strArray)

		countOfWords = Hash.new

		strArray.each do |str|
			if str.nil?
				next
			end

			# strips the string
			strippedString = str.gsub(/[^0-9A-Za-z]/, ' ')

			# splits the string into words
			splitString = strippedString.split(" ")

			# count frequency of words.
			splitString.each do |word|
				if countOfWords.has_key?(word)
					countOfWords[word] += 1
					else
					countOfWords[word] = 1
				end
			end
		end
		return countOfWords
	end
end


# Sample invocation of the class for a particular user. Uncomment and run.
# TweetWords.topWords('justinbieber', 1000)


