// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CardBase is ERC721Enumerable {
    
    string private _name = "BusinessCardNFT";
    string private _symbol = "BV";

    constructor() ERC721(_name, _symbol) {}

    // Store your personal name and phone number in storage.
    mapping(address => string) nickname;
    mapping(address => string) phoneNumber;

    // Function that sets the name and phone number.
    function setInfo(string memory _nickname, string memory _phoneNumber) public {
        nickname[msg.sender] = _nickname;
        phoneNumber[msg.sender] = _phoneNumber;
    }   

    struct Business_Card {
        //Name to be written in card (Required)
        string userName;

        //Phone number (Required)
        string phoneNum;

        //Organization (Optional)
        string organization;

        //Location - private place for business or organization location (Optional)
        string location;

        //Email address (Optional)
        string email;

        //sns ID (Optional)
        string snsID;

        //Created Date for expiration date
        uint64 creationDate;
    }

    Business_Card[] cards;

    // Function that mints the business card
    function _createBusinessCard(
        string memory _userName,
        string memory _phoneNumber,
        string memory _organization,
        string memory  _location,
        string memory  _email,
        string memory _snsID,
        address _owner
    )  internal returns (uint) {

        // Must set the required items (name and phone number) before you can create a business card.
        require(keccak256(bytes(_userName)) != keccak256(""), "Set your nickname first!");
        require(keccak256(bytes(_phoneNumber)) != keccak256(""), "Set your phone number first!");

        Business_Card memory _newCard = Business_Card({
            userName: _userName,
            phoneNum: _phoneNumber,
            organization: _organization,
            location: _location,
            email: _email,
            snsID: _snsID,
            creationDate: uint64(block.timestamp)
        });

        cards.push(_newCard);
        uint256 newCardId = cards.length -1;

        _safeMint(_owner, newCardId);

        return newCardId;
    }

    // Function to transfer business cards using the '_safeTransfer' in ERC721.
    function _cardtransfer(address _from, address _to, uint256 _tokenId)  internal virtual{
        _safeTransfer(_from,_to,_tokenId,'hello');
    }


}

/// @title Contract that inherits from CardBase to mint personal business cards. 
contract Personal is CardBase{ 
    // Save the number of business cards that have minted so far.
    mapping (address => uint) mintCount;

    // Function that mints personal business card. 
    // Mint 10 cards at a time.
    // After the first 10 mints, you have to pay 1 ether to mint 10 business cards.
    function createPersonalCard(
        string memory _location,
        string memory _email,
        string memory _snsID
    ) external payable {
        if(mintCount[msg.sender]>=10){
            require(msg.value == 1 ether, "You need to send exactly 1 ETH to mint your business card.");
        }

        for(uint8 i=0; i<10; i++){
            _createBusinessCard(nickname[msg.sender], phoneNumber[msg.sender],'NULL',_location,_email,_snsID,msg.sender);
            mintCount[msg.sender]++;
        }
    }
}

/// @title Contract that inherits from CardBase 
/// to grant organization authorization and mint Organization business cards.
contract Organization is Personal{
    //save authorized organizations
    mapping(address => bool) private organizations;
    //set organization information(name, location)
    mapping(address => string) private orgName;
    mapping(address => string) private orgLocation;
    //save authorized members of organization
    mapping(address => address[]) orgMembers;

    // By paying 2 ether to the contract, you gain the authority of the organization.
    function deposit() external payable {
        require(msg.value == 2 ether, "You must deposit 2 ether to register as organization.");
        organizations[msg.sender] = true;
    }

    // Function that set organization information(name, location)
    // only organization account can call this function.
    function _setOrganizationInfo(string memory _name, string memory _location) internal {
        require(organizations[msg.sender]==true, "Only possible for organization's account");
        orgName[msg.sender]=_name;
        orgLocation[msg.sender]=_location;
    }

    // Function that add member to organization.
    // only organization account can call this function.
    function _addMember(address _member) internal{
        require(organizations[msg.sender]==true, "Only possible for organization's account");
        orgMembers[msg.sender].push(_member);
    }

    // A function that mints the business card of an organization member. 
    // Unlike personal business card minting, 
    // you must enter the name and phone number of the member who will receive the business card.
    // Only members in 'orgMembers' can be given the minted business card.
    // In the same way with personal business card minitng, mints 10 cards at a time.
    function createOrganizationCard(
        string memory _email,
        string memory _snsID,
        address _to
    ) external{
        bool isMember = false;
        for (uint i = 0; i < orgMembers[msg.sender].length; i++) {
            if (orgMembers[msg.sender][i] == _to) {
            isMember = true;
            break;
            }
        }
        require(isMember, "Only possible for organization member");

        for(uint8 i=0; i<10; i++){
            uint256 newCardId =_createBusinessCard(
                nickname[_to],phoneNumber[_to], orgName[msg.sender],orgLocation[msg.sender],_email,_snsID,msg.sender);
            mintCount[msg.sender]++;
            _cardtransfer(msg.sender,_to, newCardId);
        }
    }
}