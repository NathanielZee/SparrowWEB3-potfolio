// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract  Twiter is Ownable {
    uint16 public MAX_TWEET_LENGTH=280; 
     
     struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
     }
     mapping (address => Tweet[] ) public tweets;

     event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
     event TweetLiked(address liker, address tweetauthor, uint256 tweetId, uint256 newlikecount);
     event TweetUliked( address unliker, address tweetauthor, uint256 tweetId, uint256 newlikecount );


     function changetweetlength(uint16 newTweetlength) public onlyOwner{
      MAX_TWEET_LENGTH =newTweetlength;
     }

function gettotalLikes(address _author) external view returns (uint256) {
    uint totalLikes;

      for(uint i=0; i< tweets[_author].length; i++){
        totalLikes += tweets[_author][i].likes;
      }

return totalLikes;

}



     function createTweet(string memory _tweet) public {
        require( bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long");

        Tweet memory newTweet =Tweet({
            id: tweets[msg.sender].length,  
            author:msg.sender,
            content: _tweet,
            timestamp:block.timestamp,
            likes:0
        });

        tweets[msg.sender].push(newTweet);

        emit TweetCreated (newTweet.id, newTweet.author,newTweet.content, newTweet.timestamp);
     }

     function likeTweet(address author, uint256 id) external {
         require(tweets[author][id].id ==id, "Tweet does not exist");

        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
     }

function unlikeTweet( address author, uint256 id) external {
   require(tweets[author][id].id ==id, "Tweet does not exist");
   require(tweets[author][id].likes >0, "tweet dosn't have any likes");

   tweets[author][id].likes--;

   emit TweetUliked(msg.sender, author, id, tweets[author][id].likes);
}

function getTweet(uint _i) public view returns (Tweet memory)  {
        return tweets[msg.sender] [_i];
       }

     function getALLTWeets( address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
  }  
}