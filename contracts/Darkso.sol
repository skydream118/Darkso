
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

    uint256 public _totalPresale;
    uint256 private PresaleIssue;
    uint8 private _tokenDecimals = 6;

    bool private canPresale = true;

    uint256 private _rate;

    address private lockedWallet;

    address private OpenWallet = 0xF8a29F60Fd8923d6dD04B22bDa3e7730Aac35C98;

    address private liquidityWallet = 0xdc2e61ae8A109C10691967c9B4850F000214F2Ea;

    uint256 private TokenWithdrawTime;

    struct PresaleRecord{
        uint256 issue;
                
        uint256 icoTotal;
        
        uint256 startTime;
        
        uint256 duration;
        
        uint256 maxLimitPerUser;

        uint256 receivedTotal;
        
        mapping(address => uint256) TokenAmount;
    }

    mapping(uint256 => PresaleRecord) public ICODB;

    event PresaleCreate(uint256 PresaleIssue, uint256 maxLimitPerUser, uint256 PresaleAmount, uint256 startTime, uint256 blocktimenow ,uint256 duration);

    event BuyTokens(uint256 PresaleIssue, address indexed from, uint256 tokenAmount);

    event TokenWithdraw(address OpenWallet, address lockedWallet, uint256 tokenAmount);

    constructor() ERC20(_name,_symbol) {
        _totalSupply = 300e12;
        lockedWallet = _msgSender();

        _mint(lockedWallet,260e12);
        _mint(OpenWallet,35e12);
        _mint(liquidityWallet,5e12);

        TokenWithdrawTime = block.timestamp;

    }
    receive() external payable {}

    function setRate(uint256 newRate) external onlyOwner{
        _rate = newRate;
    }

    function startPresale(
        uint256 PresaleAmount,
        uint256 startTime,
        uint256 duration,
        uint256 maxLimitPerUser
    )external onlyOwner{

        require( canPresale, "Presale will be disable until new token withdraw");
        require( block.timestamp >
            ICODB[PresaleIssue].startTime.add( ICODB[PresaleIssue].duration),
            "presale is not over yet");
        PresaleIssue = PresaleIssue.add(1);
        PresaleRecord storage ico = ICODB[PresaleIssue];
        ico.issue = PresaleIssue;
        ico.icoTotal = PresaleAmount;
        ico.startTime = startTime;
        ico.duration = duration;
        ico.maxLimitPerUser = maxLimitPerUser;

        canPresale = false;
        _totalPresale = 0;

        _transfer(OpenWallet, address(this), PresaleAmount);

        emit PresaleCreate(
            PresaleIssue,
            //TokenPrice,
            maxLimitPerUser,
            PresaleAmount,
            startTime,
            block.timestamp,
            duration
        );
    }


    function Buy_Tokens() external payable{

        require(msg.sender != address(0), "address is 0");

        require(PresaleIssue > 0, "Presale that does not exist");

        require( block.timestamp >= ICODB[PresaleIssue].startTime &&
            block.timestamp < ICODB[PresaleIssue].startTime + ICODB[PresaleIssue].duration,
                 "Presale is not in progrsess.");

        require( _totalPresale < ICODB[PresaleIssue].icoTotal, "Not enough tokens left");


        PresaleRecord storage record = ICODB[PresaleIssue];

        uint256 tokenAmount = _getTokenAmount(msg.value);
        require( record.TokenAmount[msg.sender].add(tokenAmount) <= record.maxLimitPerUser,
                 "amount cannot bigger than maxLimitAmount");
        
        record.TokenAmount[msg.sender] += tokenAmount;
        _totalPresale += tokenAmount;
        _transfer(address(this), msg.sender, tokenAmount);

        emit BuyTokens(PresaleIssue, msg.sender, tokenAmount);
    } 

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate).div(10**(18-_tokenDecimals));
    }

    function decimals() public view override returns (uint8) {
        return _tokenDecimals;
    }

    function withdrawToken() external onlyOwner{

        require(block.timestamp - TokenWithdrawTime >= 30 days, "Now is not time for withdraw token");
        
        _transfer(lockedWallet, OpenWallet, 26e12);

        TokenWithdrawTime = block.timestamp;
        canPresale = true;
        emit TokenWithdraw(lockedWallet, OpenWallet, 26e12);
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_msgSender() != lockedWallet, "lockedWallet cannot transfer tokens to another");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
}