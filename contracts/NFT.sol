// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721,Ownable {

    using Strings for uint256;

    uint256 MAX_SUPPLY = 100;
    bool isSaleActive = false;
    uint256 totalSupply=0;
    string baseURI = "ipgs:://QmfA7poczzdtoXrE1UjTDPJog1hMoFbrtWeKtRHHw2eMWo";
    mapping(uint256 => uint256) tokenMetaDataNo; //tokenID에 할당된 metadata number

    constructor() ERC721("TH_NFT","MTH"){
       
    }

    function setBaseURI(string memory uri) external onlyOwner{
        // base uri 변경
        baseURI = uri;
    } 

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setSale (bool active) external onlyOwner {
        isSaleActive = active;
    }

    function mintPlanet (uint256 count) external payable{
        
        require(isSaleActive,"not on sale");
        require(msg.value >= 1000000000000000 * count); //0.01 eth * count 
        require(count <=10 , "min maximun 10 nfts at once");

        for(uint i=0;i<count;i++){
            require(totalSupply < MAX_SUPPLY , "max supply exceeded");
            // block 해쉬로 랜덤값 생성 말고 chain link로 나중에 바꾸자 
            tokenMetaDataNo[totalSupply] = 1 + uint256(blockhash(block.number)) % 8; //마지막 블록의 해쉬 
            _safeMint(msg.sender, totalSupply++);
        }

    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory get_baseURI = _baseURI();
        return string(abi.encodePacked(get_baseURI, tokenMetaDataNo[tokenId].toString())) ;
    }

    function withdraw() external onlyOwner {
        //msg.sender == contract owner 
        payable(msg.sender).transfer(address(this).balance);
    }


}