#!/usr/bin/python
import sys
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import json
import csv
import datetime
import string, re
import hashlib

# Go to http://dev.twitter.com and create an app.
# The consumer key and secret will be generated
consumer_key=""
consumer_secret=""

# After the step above, you will be redirected to your app's page.
# Create an access token under the the "Your access token" section
access_token=""
access_token_secret=""

class StdOutListener(StreamListener):
    """ A listener handles tweets are the received from the stream.
This is a basic listener that just prints received tweets to stdout.

"""
    def on_data(self, data):
        decoded_str = json.loads(data)
        track_emotions(decoded_str[ 'text' ])
        return True

    def on_error(self, status):
        print status


def track_emotions(s):
	global count
	count+=1
	wordcount=0

	if (count % 10 == 0):
		s=s.lower()
		out = re.sub('[%s]' % re.escape(string.punctuation), '', s)
		out = out.encode('ascii', 'ignore')
		arr = out.split();

		valence_total=0
		dominance_total=0
		arousal_total=0
		val=0

		for i in range(0,len(arr)):
			try:
				valence_total += valence[ arr[i] ]
				wordcount+=1
			except KeyError:
				pass
			try:
				dominance_total += dominance[ arr[i] ]
				wordcount+=1
			except KeyError:
				pass

			try:
				arousal_total += arousal[ arr[i] ]
				wordcount+=1
			except KeyError:
				pass
		h.update(out)
		print datetime.datetime.now(),"\t",h.hexdigest(),"\t",str(wordcount),"\t",str(valence_total), "\t", str(arousal_total) , "\t", str(dominance_total)
		sys.stdout.flush()
		count = 0

if __name__ == '__main__':
	global valence
	global arousal
	global dominance
	global h
	global count

	count = 0


	h = hashlib.new('md5')
	valence={}
	arousal={}
	dominance={}

	with open("word_ratings.txt") as f:
		reader = csv.reader(f, delimiter="\t")
		d=list(reader)

	for i in range(1,len(d)):
		valence[ d[i][1] ] = float(d[i][2])
		arousal[ d[i][1] ] = float(d[i][5])
		dominance[ d[i][1] ] = float(d[i][8])

	while(1):
		try:
			l = StdOutListener()
			auth = OAuthHandler(consumer_key, consumer_secret)
			auth.set_access_token(access_token, access_token_secret)
			stream = Stream(auth, l)
			stream.filter(track=['feel'])
		except Exception:
			sys.exc_clear()


