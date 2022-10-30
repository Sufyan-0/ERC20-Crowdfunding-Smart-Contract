// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ERC20.sol";

contract CrowdFunding{

    uint public CampignCount;
    IERC20 public  token;

    mapping(uint => mapping(address => uint)) public pledgedAmount;
    mapping (uint => Creater) public Creaters;
     
    constructor(address _token){
    token = IERC20(_token);
    }


    struct Creater{
        address owner;
        uint id;
        uint goal;
        uint donatingAmount;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    struct Donater{
        address donater;
        uint compaignID;
        uint amount;
    }
 
 
    function creater(uint _goal)public{
      require(_goal > 0 , "Goal is not Equal to Zero");
      CampignCount++;
      Creaters[CampignCount] = Creater(msg.sender , CampignCount , _goal , 0 ,block.timestamp , block.timestamp + 10 ,false);
    }

// Donateing Money
    function pledge(uint _compaignID , uint _amount ) public {
        Creater storage CreaterVar = Creaters[_compaignID];
        require(CreaterVar.endAt >= block.timestamp ,"This Compaign Has been Ended");
        CreaterVar.donatingAmount +=_amount;     

        pledgedAmount[_compaignID][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount); 
    }

// Donater withdraw money they are not donating 
    function unplege(uint _compaignID , uint _amount )public{
        Creater storage CreaterVar = Creaters[_compaignID];

        if(CreaterVar.endAt >= block.timestamp ){
             pledgedAmount[_compaignID][msg.sender] -= _amount;
             CreaterVar.donatingAmount -=_amount; 
             token.transfer(msg.sender, _amount);
        
            }
        else if(CreaterVar.endAt <= block.timestamp ) {
            if(CreaterVar.goal >= CreaterVar.donatingAmount){
               pledgedAmount[_compaignID][msg.sender] -= _amount;
               CreaterVar.donatingAmount -=_amount; 
               token.transfer(msg.sender, _amount);
            }
            else{
                revert("Campign Is Ended");
            }
        }else{
            revert("Something went wrong 2");
        }       
    
    
    }

   function claim(uint _compaignID )public {
               Creater storage CreaterVar = Creaters[_compaignID];
               require(msg.sender == CreaterVar.owner , "only Owner Can Claimed");
               require(block.timestamp > CreaterVar.endAt , "Not ended ");
               require(CreaterVar.donatingAmount >= CreaterVar.goal , "Goal Not Completed");
               require(!CreaterVar.claimed ," Already claimed ");
               CreaterVar.claimed =true;

              token.transfer(CreaterVar.owner, CreaterVar.donatingAmount);

    }

}