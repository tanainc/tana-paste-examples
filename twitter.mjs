import Twit from "twit";
import { formatDate } from "./helpers.mjs";
import entities from "entities";

import { config } from "./config.mjs";

var T = new Twit(config.twitterToken);

const getTweets = async (url) => {
  const x = await T.get(`search/tweets`, {
    q: url,
    count: 20,
    tweet_mode: "extended",
    result_type: "popular",
  });
  return x.data.statuses;
};

const getTweetText = (x) => {
  const textRaw = entities.decode(x.full_text || x.text);
  const text = textRaw
    .replace(/(https:\/\/t\.co\S+)/, "")
    .trim()
    .replace(/\n+/g, "\n    - ");
  return text;
};

const url = process.argv[2];

console.log("%%tana%%");
getTweets(url)
  .then((tweets) => {
    tweets.forEach((firstTweet) => {
      if (getTweetText(firstTweet).trim() !== "") {
        let result = `- ${getTweetText(firstTweet).split("\n").join(" ")} #tweet
  - Tweet URL:: https://twitter.com/${firstTweet.user.screen_name}/status/${
          firstTweet.id
        }
  - Name:: [[${firstTweet.user.name}]] 
  - Twitter username:: [@${firstTweet.user.screen_name}](https://twitter.com/${
          firstTweet.user.screen_name
        })__ 
  - Date:: [[${formatDate(firstTweet.created_at)}]]`;
        console.log(result);
      }
    });
  })
  .catch((e) => console.error(e));
