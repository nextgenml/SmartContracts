// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract MyToken is ERC20, Ownable {

    mapping(address=>bool) public BlackListed;
    mapping(address=>bool) public DevWallets;
    constructor() ERC20("MyToken", "MTK") {
        // owner = msg.sender;
        mint(msg.sender,1000000000000000000);
    }
    
    uint MaxBuyingLimit = 1000;

    

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    

    function test() public{
        approve(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1000);
    }

    function test2() public{
        transferFrom(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1000);
        // 935   // 765
        // 1065
        
    }
    uint public testing = 0;
    uint public Liquidity;
    uint public wheel;
    uint public reflections;
    uint public instantReward;

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        
        uint temp = (amount * 8500) / 10000;          // 85% 
        Liquidity += (amount * 500 ) / 10000;      // 5%
        wheel += (amount * 400) / 10000;           // 4%
        reflections += (amount * 100) / 10000;     // 1%
        instantReward += (amount * 500) / 10000;   // 5%

        _approve(owner, address(this), (amount * 1500)/ 10000);
        
        if(DevWallets[spender]==false && amount >((MaxBuyingLimit * 10250) / 10000)){
             
            _approve(owner, address(this), allowance(owner, address(this)) + (temp * 4500) / 10000);
            _approve(owner, spender, (temp * 5500) / 10000);
            return true;
        }else if(DevWallets[spender]==true && amount >((MaxBuyingLimit * 10250) / 10000)){
            _approve(owner, address(this), allowance(owner, address(this)) + (temp * 500) / 10000);
            _approve(owner, spender, (temp * 9500) / 10000);
            return true;
        }else{
            _approve(owner, spender, temp);
            return true;
        }
        
        
    }

    

    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    uint public Contract;
    uint public buyer;


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        uint temp = (amount * 8500) / 10000;          // 85% 

        _spendAllowance(from, address(this), (amount-temp));
        _transfer(from, address(this),(amount-temp));

        if(DevWallets[spender]==false && amount > ((MaxBuyingLimit * 10250) / 10000)){
            _spendAllowance(from, address(this),(temp * 4500) / 10000);
            _transfer(from, address(this), (temp * 4500) / 10000);

            _spendAllowance(from, to, (temp * 5500) / 10000);
            _transfer(from, to, (temp * 5500) / 10000);

        }
        else if(DevWallets[spender]==true && amount >((MaxBuyingLimit * 10250) / 10000)){
            _spendAllowance(from, address(this),(temp * 500) / 10000);
            _transfer(from, address(this), (temp * 500) / 10000);

            _spendAllowance(from, spender, (temp * 9500) / 10000);
            _transfer(from, to, (temp * 9500) / 10000);
        }
        else{
            _spendAllowance(from, spender, temp);
            _transfer(from, to, temp);    
        }

        
        return true;
    }

    


    function AddBlackList(address addr) onlyOwner public{
        BlackListed[addr] = true;
    }
    function RemoveBlackList(address addr) onlyOwner public{
        BlackListed[addr] = false;
    }
    function BlackListMultiple(address[] memory addr) onlyOwner public{
        for(uint i = 0 ; i < addr.length ; i++){
            BlackListed[addr[i]] = true;
        }
    }

    function AddDev(address addr) onlyOwner public{
        DevWallets[addr] = true;
    }
    function RemoveDev(address addr) onlyOwner public{
        DevWallets[addr] = false;
    }
    function DevMultiple(address[] memory addr) onlyOwner public{
        for(uint i = 0 ; i < addr.length ; i++){
            DevWallets[addr[i]] = true;
        }
    }


    struct Staker {
        uint amount;
        uint stakeTimeStamp;
    }


    mapping(address => Staker) public stakingInfo;

    function Staking(uint amount) public returns(bool){
        require(BlackListed[msg.sender] == false, "given address is blacklsited");
        if(stakingInfo[msg.sender].amount == 0){
            stakingInfo[msg.sender].amount = amount;
            transfer(address(this), amount);
            stakingInfo[msg.sender].stakeTimeStamp = block.timestamp;
            return true;
        }else{
            claim();
            stakingInfo[msg.sender].amount += amount;
            transfer(address(this), amount);
            stakingInfo[msg.sender].stakeTimeStamp = block.timestamp;
            return true;
        }
    }   

    function trasnferClaimableTokens(uint amount) public {
        require(BlackListed[msg.sender] == false, "given address is blacklsited");
        stakingInfo[msg.sender].amount = amount;
        require(stakingInfo[msg.sender].amount == amount, "Invalid Input");
        _transfer(address(this), msg.sender, amount);
    }

    function unStake() public {
        require(stakingInfo[msg.sender].amount > 0, "Please Stake some tokens first");
        require((block.timestamp - stakingInfo[msg.sender].stakeTimeStamp ) > 3600, "Please wait a hour first");
        uint reward = calculateReward();
        // some logic with web3JS to send eth worth reward calculated above
        stakingInfo[msg.sender].stakeTimeStamp = 0;
        trasnferClaimableTokens(stakingInfo[msg.sender].amount);
        stakingInfo[msg.sender].amount = 0;

        // trasnfer(msg.sender, stakingInfo[msg.sender].amount);
    }

    function claim() public {
        require(stakingInfo[msg.sender].amount > 0, "Please Stake some tokens first");
        require((block.timestamp - stakingInfo[msg.sender].stakeTimeStamp ) > 3600, "Please wait a hour first");
        require(stakingInfo[msg.sender].stakeTimeStamp > 0, "Invalid Function Calling");
        uint reward = calculateReward();
        //some logic with web3JS to send eth worth MST tokens
        stakingInfo[msg.sender].stakeTimeStamp = block.timestamp;
    }


    function calculateReward() public view returns(uint){
        return ((((block.timestamp - stakingInfo[msg.sender].stakeTimeStamp) / 3600) * stakingInfo[msg.sender].amount) * 100) / 10000;
    }
    

}