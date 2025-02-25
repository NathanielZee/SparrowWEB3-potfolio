// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SparrowNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;
    
    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }
    
    struct Comment {
        uint256 postId;
        address author;
        string content;
        uint256 timestamp;
    }
    
    uint256 public postCounter;
    mapping(uint256 => Post) public posts;
    mapping(uint256 => Comment[]) public comments;
    mapping(uint256 => mapping(address => bool)) public likedPosts;
    
    event NewPost(uint256 indexed postId, address indexed author, string content);
    event NewComment(uint256 indexed postId, address indexed author, string content);
    event PostLiked(uint256 indexed postId, address indexed liker);
    
    struct NFT {
        uint256 id;
        address payable owner;
        uint256 price;
        bool forSale;
    }
    
    mapping(uint256 => NFT) public nfts;
    event NFTMinted(uint256 indexed tokenId, address owner, string tokenURI);
    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTSold(uint256 indexed tokenId, address buyer);
    
    constructor() ERC721("SparrowNFT", "SPNFT") Ownable(msg.sender)  {}
        
    
    function mintNFT(string memory tokenURI, uint256 price) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        nfts[newItemId] = NFT(newItemId, payable(msg.sender), price, false);
        emit NFTMinted(newItemId, msg.sender, tokenURI);
    }

    function getTotalMinted() public view returns (uint256) {
    return _tokenIds.current();
}

    
    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        nfts[tokenId].price = price;
        nfts[tokenId].forSale = true;
        emit NFTListed(tokenId, price);
    }
    
    function buyNFT(uint256 tokenId) public payable {
        require(nfts[tokenId].forSale, "NFT not for sale");
        require(msg.value >= nfts[tokenId].price, "Insufficient funds");
        
        address seller = nfts[tokenId].owner;
        nfts[tokenId].owner = payable(msg.sender);
        nfts[tokenId].forSale = false;
        payable(seller).transfer(msg.value);
        _transfer(seller, msg.sender, tokenId);
        emit NFTSold(tokenId, msg.sender);
    }
    
    function createPost(string memory _content) public {
        posts[postCounter] = Post(postCounter, msg.sender, _content, block.timestamp, 0);
        emit NewPost(postCounter, msg.sender, _content);
        postCounter++;
    }
    
    function commentOnPost(uint256 _postId, string memory _content) public {
        require(_postId < postCounter, "Post does not exist");
        comments[_postId].push(Comment(_postId, msg.sender, _content, block.timestamp));
        emit NewComment(_postId, msg.sender, _content);
    }
    
    function likePost(uint256 _postId) public {
        require(_postId < postCounter, "Post does not exist");
        require(!likedPosts[_postId][msg.sender], "Already liked");
        posts[_postId].likes++;
        likedPosts[_postId][msg.sender] = true;
        emit PostLiked(_postId, msg.sender);
    }
}
