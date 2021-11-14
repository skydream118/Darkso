
pragma solidity ^0.8.0;
// SPDX-License-Identifier: None

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract DARKSO is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 private _totalSupply;
    string private _name = "DarkSwordOnline";
    string private _symbol = "DARKSO";

    uint256 private _PresaleLimit = 45e12;
    uint256 private _totalPresale;
    uint8 private _tokenDecimals = 6;
    uint256 private _PresaleLimitPerUser = 1e12;

    bool private canPresale = true;

    uint256 private _bnbRate; //Ex 1000 Darkso = 1 BNB : set 1000
    uint256 private _coinRate; //Ex 100 coin = 1 Darkso : set 100

    address private OpenWallet = 0xF8a29F60Fd8923d6dD04B22bDa3e7730Aac35C98;

    address private liquidityWallet = 0x704e18De9fdA90aBB0e80aaD8CCf6E8B1b73e6fa;
    //0xdc2e61ae8A109C10691967c9B4850F000214F2Ea;


    event BuyTokens(address indexed from, uint256 tokenAmount);

    event TokenWithdraw(address OpenWallet, address lockedWallet, uint256 tokenAmount);

    event ExchangeToken(address recipient,uint256 extoken);

    event ExchangeCoin(address recipient, uint256 exCoin, uint256 exToken);

    constructor() ERC20(_name,_symbol) {

        _totalSupply = 300e12;        
        _mint(address(this),255e12);
        _mint(OpenWallet,15e12);
        _mint(liquidityWallet,30e12);

    }
    receive() external payable {}

    function setBNBRate(uint256 newRate) external onlyOwner{
        _bnbRate = newRate;
    }
    function setCoinRate(uint256 newRate) external onlyOwner{
        _coinRate = newRate;
    }

    function getCoinRate()public view returns(uint256){
        return _coinRate;
    }

    function startPresale()external onlyOwner{

        require( canPresale, "Presale will be disable until new token withdraw");
        canPresale = false;
        _totalPresale = 0;
    }


    function Buy_Tokens() external payable{

        require(msg.sender != address(0), "address is 0");

        require( _totalPresale < _PresaleLimit, "Not enough tokens left");

        uint256 tokenAmount = _getTokenAmount(msg.value);
        require( balanceOf(msg.sender).add(tokenAmount) <= _PresaleLimitPerUser,
                 "amount cannot bigger than maxLimitAmount");
         
        _totalPresale += tokenAmount;
        _transfer(address(this), msg.sender, tokenAmount);

        emit BuyTokens(msg.sender, tokenAmount);
    }

    //sending token from contract wallet to the recipient wallet
    function exchange_tokenTocoin(uint256 extoken,address sender) public onlyOwner returns (bool){
        transferFrom(sender, address(this), extoken);

//        _transfer(sender, address(this), extoken);
        emit ExchangeToken(sender, extoken);
        return true;
    }

    //sending token from recipient wallet to the contract wallet
    function exchange_coinTotoken(uint256 exCoin, address recipient) public onlyOwner returns (bool){
        
        uint256 exToken;
        exToken = _getTokenAmount_Coin(exCoin);
        _transfer(address(this), recipient, exCoin);
        emit ExchangeCoin(recipient, exCoin, exToken);
        return true;
    } 

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_bnbRate).div(10**(18-_tokenDecimals));
    }

    function _getTokenAmount_Coin(uint256 weiAmount) internal view returns (uint256){
        return weiAmount.div(_coinRate);
    }


    function decimals() public view override returns (uint8) {
        return _tokenDecimals;
    }

    function getOwner() public view returns (address) {
        return OpenWallet;
    }

    function withdrawBNB(address payable recipient) public onlyOwner {
        require(address(this).balance > 0, 'Contract has no money');
        recipient.transfer(address(this).balance);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
}