import GetOldTweets3 as got
import pandas as pd
import datetime


class Collector:
  '''
  from collector import Collector 하고나서, 
  c = Collector("2020-06-17", "2020-06-18", "자가격리", "자가격리_0617to0618.csv") 와 같이 설정 후, 
  c.collect() 라고 하면 저장까지 됨'''
  
  def __init__(self, fromdate, untildate, keyword, output):
    self.fromdate = fromdate
    self.untildate = untildate
    self.keyword = keyword
    self.output = output
  
  def date(self):
    start = datetime.datetime.strptime(self.fromdate, "%Y-%m-%d")
    end = (datetime.datetime.strptime(self.untildate, "%Y-%m-%d") + datetime.timedelta(days=1)) # setUntil이 끝을 포함하지 않으므로, day + 1
    date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]
    days_range = []
    for date in date_generated:
      days_range.append(date.strftime("%Y-%m-%d"))
    return days_range

  def collect(self):
    days_range = self.date()
    start_date = days_range[0]
    end_date = (datetime.datetime.strptime(days_range[-1], "%Y-%m-%d") 
              + datetime.timedelta(days=1)).strftime("%Y-%m-%d") # setUntil이 끝을 포함하지 않으므로, day + 1
    tweetCriteria = got.manager.TweetCriteria().setQuerySearch(self.keyword)\
                                             .setSince(start_date)\
                                             .setUntil(end_date)\
                                             .setMaxTweets(-1)

    tweet = got.manager.TweetManager.getTweets(tweetCriteria)
    tweet_list = [i.text for i in tweet]
    twitter_df = pd.DataFrame(tweet_list, columns = ["text"])
    twitter_df.to_csv(self.output, index=False)
    
  def __str__(self):
    return 'from collector import Collector 하고나서, c = Collector("2020-06-17", "2020-06-18", "자가격리", "자가격리_0617to0618.csv") 와 같이 설정 후, c.collect() 라고 하면 저장까지 됨'


  
  

