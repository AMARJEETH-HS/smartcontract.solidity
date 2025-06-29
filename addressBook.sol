// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 // this is an example code of solidity smartcontract this is like an addressBook which will store the all the contract retlated information its specified name and address of msg.sender

contract addressBook {

    mapping(address => address[]) private contractaddrs ;
    mapping(address => mapping(address => string )) private contractname;


    function getcontract() public view returns (address [] memory ){
        return contractaddrs[msg.sender];
    }


    function addcontracts(address _contractaddrs ,string memory _contractname) public {
        contractaddrs[msg.sender].push(_contractaddrs);
        contractname[msg.sender][_contractaddrs] = _contractname;
    }

    function getcontractname(address _contractaddr) public view returns (string memory){
         return contractname[msg.sender][_contractaddr];
    }

     function removeContact(address contactAddress) public {
        uint256 length = contractaddrs[msg.sender].length;
        for (uint256 i = 0; i < length; i++) {
            if (contactAddress == contractaddrs[msg.sender][i]) {
                if (contractaddrs[msg.sender].length > 1 && i < length - 1) {
                    contractaddrs[msg.sender][i] = contractaddrs[msg.sender][length - 1];
                }

                contractaddrs[msg.sender].pop();

                delete contractname[msg.sender][contactAddress];
                break;
            }
        }
    }
}
