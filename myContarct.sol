// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract sample{
    uint public age ;
    string public name ;

    function setage(uint _age) public {
        age=_age;
    }
    
    function setname (string memory _name )public{
        name = _name;
    }
}
