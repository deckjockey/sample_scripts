filename = 'index.html'

import sys
import re

def removehtml(html):
  cleanr = re.compile('<.*?>')
  clean = re.sub(cleanr, '', html)
  return clean

word_count_dict = {}

with open(filename,'r') as readfile:
  for line in readfile:
    line = removehtml(line)
    word_list = line.replace('!',' ').replace(',',' ').replace('.',' ').lower().split()
    for word in word_list:
      if word not in word_count_dict:
        word_count_dict[word] = 1
      else:
        word_count_dict[word] = word_count_dict[word] + 1

for key, value in sorted(word_count_dict.iteritems(), key=lambda (k,v): (v,k)):
    last_value = value
    last_key = key

sys.stdout = open("wordcount.log", "w+")
print "The word '%s' appears %s times in %s" % (last_key, last_value, filename)
