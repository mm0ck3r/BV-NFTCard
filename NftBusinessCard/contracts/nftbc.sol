// SPDX-License-Identifier: MIT
/*
한 사람이 여러 개의 토큰(명함)을 만들 수 있다..
*/
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

struct CardStruct{
    string name;
    string description;
    string phone;
    string email;
    string organization;
    string url;
    address userAddr;
}

contract BusinessCard is ERC721Enumerable{
    uint tokenId;
    string private _TokenName = "mm0ck3rCardNFT";
    string private _symbol = "MMBVCARD";
    constructor() ERC721(_TokenName, _symbol){}
    mapping(address => uint256[]) user_cards; // cards that user made.
    mapping(address => CardStruct) user_info;
    mapping(address => uint256) amountOfCardsthatMade;
    CardStruct[] all_cards;

    event _makeInfo(
        string name,
        string description,
        string phone,
        string email,
        string organization,
        string url,
        address userAddr
    );

    event _makeCard(
        string name,
        address userAddr,
        uint tokenId,
        uint nowAmount
    );

    event _transferCard(
        address from,
        address to,
        uint256 tokenId,
        uint nowAmount
    );
    function makeInfo(
        string memory _name,
        string memory _description,
        string memory _phone,
        string memory _email,
        string memory _organization,
        string memory _url
    )public{
        user_info[msg.sender] = CardStruct(
            _name,
            _description,
            _phone,
            _email,
            _organization,
            _url,
            msg.sender
        );
        emit _makeInfo(_name, _description, _phone, _email, _organization, _url, msg.sender);
    }
    function makeCard() public payable{
        require(user_info[msg.sender].userAddr == msg.sender, "register your info");
        _mint(msg.sender, ++tokenId);
        user_cards[msg.sender].push(tokenId);
        amountOfCardsthatMade[msg.sender]++;
        all_cards.push(
            CardStruct(
                user_info[msg.sender].name,
                user_info[msg.sender].description,
                user_info[msg.sender].phone,
                user_info[msg.sender].email,
                user_info[msg.sender].organization,
                user_info[msg.sender].url,
                msg.sender
            )
        );
        emit _makeCard(user_info[msg.sender].name, msg.sender, tokenId, amountOfCardsthatMade[msg.sender]);
    }
    function transferCard(address to) public{
        require(amountOfCardsthatMade[msg.sender] > 0, "Make more Cards");
        bool possible = false;
        uint256 cardIdtoGive;
        uint256 delidx;
        for(uint i=0; i<user_cards[msg.sender].length; i++){
            if(all_cards[user_cards[msg.sender][i]].userAddr == msg.sender){
                cardIdtoGive = user_cards[msg.sender][i];
                possible = true;
                delidx = i;
                break;
            }
        }
        if(possible){
            uint256 tmp;
            safeTransferFrom(msg.sender, to, cardIdtoGive);
            tmp = user_cards[msg.sender][user_cards[msg.sender].length - 1];
            user_cards[msg.sender][user_cards[msg.sender].length - 1] = user_cards[msg.sender][delidx];
            user_cards[msg.sender][delidx] = tmp;
            user_cards[msg.sender].pop();
            amountOfCardsthatMade[msg.sender]--;
            user_cards[to].push(cardIdtoGive);
            emit _transferCard(msg.sender, to, cardIdtoGive, amountOfCardsthatMade[msg.sender]);
        }
        else{
            // how to occur an error?
            revert("no more card."); // is it right?
        }
    }

    function borrowCard(address who, address to) public{ // A가 B에게 준 A의 카드를, A의 정보를 필요로 하는 C에게 B가 빌려주는 걸 어떻게 구현하지?

    }
}