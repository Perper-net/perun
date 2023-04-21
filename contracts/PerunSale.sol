// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PerunSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public token;
    address public usdt;
    address public treasury;    
    address public perunForSale;

    uint256 public tokensSold = 0;
    uint256 public usdtDesposited = 0;

    uint256 private decimalsDiference = 1000000000000; //Difference between token and usdt decimal places
    uint256 private rate = 16; //Rate is given like this so when divided by 100 gives correct number


    constructor (address _tokenAddress, address _usdtAddress, address _perunForSale, address _treasury){
        token = _tokenAddress;
        usdt = _usdtAddress;
        perunForSale = _perunForSale;
        treasury = _treasury;
    }

    mapping (address => uint256) private userTokenBought;
    mapping (address => uint256) private userUsdtSpent;

    event usdtDepositComplete(address usdt, uint256 amount);
    event tokenSaleComplete(address token, uint256 amount);


    function buyToken(uint256 amount) public {
        require(IERC20(usdt).balanceOf(msg.sender) >= amount, "Usdt amount must be greater than deposit.");
        require(IERC20(usdt).allowance(msg.sender, address(this)) >= amount, "Allowance lower than desired Usdt value.");
        uint256 tokenAmount = calculateTokenAmount(amount);
        require(IERC20(token).allowance(perunForSale, address(this)) >= tokenAmount, "Allowance lower than desired Perun value");

        IERC20(usdt).safeTransferFrom(msg.sender, treasury, amount);
        userUsdtSpent[msg.sender] += amount;
        usdtDesposited += amount;
        emit usdtDepositComplete(usdt, amount);

        IERC20(token).safeTransferFrom(perunForSale, msg.sender, tokenAmount);
        userTokenBought[msg.sender] += tokenAmount;
        tokensSold += tokenAmount;
        emit tokenSaleComplete(token, tokenAmount);
    }

    function calculateTokenAmount(uint256 amount) private view returns(uint256) {
        uint256 calculated = amount.div(rate).mul(100);
        calculated = calculated.mul(decimalsDiference);
        return calculated;
    }

    function getAddressUsdtPerun(address _address) view public onlyOwner returns(uint256, uint256) {
        return (userTokenBought[_address], userUsdtSpent[_address]);
    }

    function setUsdt(address _address) public onlyOwner {
        usdt = _address;
    }

    function setPerun(address _address) public onlyOwner {
        token = _address;
    }

    function setPerunForSale(address _address) public onlyOwner {
        perunForSale = _address;
    }

    function setTreasury(address _address) public onlyOwner {
        treasury = _address;
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function setDecimalsDifference(uint256 _decimals) public onlyOwner {
        decimalsDiference = _decimals;
    }


}