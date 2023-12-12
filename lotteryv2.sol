// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./VRFv2Consumer.sol";

contract Lottery{
    address public manager;
    address payable[] public players;
    VRFv2Consumer internal consumerContract;

    enum LOTTERY_STATE{
        OPEN, CLOSE, CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    constructor(){
        manager = msg.sender;
        lottery_state = LOTTERY_STATE.OPEN;
        //Use the VRF Consumer Contract
        consumerContract = VRFv2Consumer(0x392F73425Fd7280150e91114FE36509191E2a5cc);
    }

    //Function to add the player to the list
    receive() payable external{
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not opened at the moment");
        require(msg.value == 0.01 ether, "Must Pay 0.01 ETH to Enter the Lottery");
        players.push(payable(msg.sender));
    }

    //Function to get Player's addresses (MANAGER ONLY)
    function getPlayers() public managerOnly view returns(address payable[]memory){
        return players;
    }

    //Function to request random number using Chainlink VRF
    function requestVRF() public managerOnly {
        consumerContract.requestRandomWords();
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
    }

    //Function to check the requested random number
    function checkVRFResponse() internal view
    returns(bool fulfilled, uint256[] memory randomNumbers){
        uint requestID = consumerContract.lastRequestId();
        (fulfilled, randomNumbers) = consumerContract.getRequestStatus(requestID);
    }

    //Function to pick the Lottery's Winner (MANAGER ONLY)
    function pickWinner() public managerOnly{
        require(players.length >= 3, "Requires At Least 3 Players to Pick Winner!");
        (bool fulfilled, uint[] memory randomNumbers) = checkVRFResponse();
        require(fulfilled, "Random number request hasn't been fulfilled");

        uint index = randomNumbers[0] % players.length;
        address payable winner = players[index];
        
        (bool sentManager, ) = manager.call{value: address(this).balance/10}("");
        require(sentManager, "Failed to send money to manager");
        (bool sentWinner, ) = winner.call{value: address(this).balance}("");
        require(sentWinner, "Failed to send money to winner");
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.OPEN;
    }

    //Function to close the Lottery
    function closeLottery() public managerOnly{
        require(players.length == 0, "Players have entered");
        lottery_state = LOTTERY_STATE.CLOSE;
    }

    //Function to open the Lottery
    function openLottery() public managerOnly{
        lottery_state = LOTTERY_STATE.OPEN;
    }

    //Modifier that requires function to be called by manager only
    modifier managerOnly{
        require(msg.sender == manager, "Function can only be called by manager");
        _;
    }
}