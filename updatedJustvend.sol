// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JustVend {
    enum status { present, notpresent }
    enum machinestat { on, off }

    machinestat public condition;

    struct item {
        uint256 itemCount;
        uint256 priceInEther; 
        status stat;
    }

    mapping(string => item) public items;
    string[]  itemNames;

    event order(string name, uint256 paidInEther);

    address payable public immutable owner;

    constructor() {
        owner = payable(msg.sender); // Deployer becomes the permanent owner
        condition = machinestat.on;
    }

    modifier onlyowner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier ispresent(string memory _itemName) {
        require(items[_itemName].stat == status.present, "Item not present");
        _;
    }

    modifier machineOn() {
        require(condition == machinestat.on, "Machine is turned off");
        _;
    }

    
    function cahngemachinecond() public onlyowner {
        if (condition == machinestat.on) {
            condition = machinestat.off;
        } else {
            condition = machinestat.on;
        }
    }

    function listitems(string memory itemname, uint256 noOfItems, uint256 priceEther) public onlyowner {
        require(priceEther > 0, "Price must be greater than 0");

        bool alreadyExists = false;
        for (uint256 i = 0; i < itemNames.length; i++) {
            if (keccak256(bytes(itemNames[i])) == keccak256(bytes(itemname))) {
                alreadyExists = true;
                break;
            }
        }

        if (!alreadyExists) {
            itemNames.push(itemname);
        }

        items[itemname].itemCount += noOfItems;
        items[itemname].priceInEther = priceEther;
        items[itemname].stat = status.present;
    }

    function getitems() public view returns (string[] memory) {
        return itemNames;
    }

    // Buyer orders item and pays in Ether
    function orderItem(string memory _itemName, uint256 _quantity)
        external
        payable
        machineOn
        ispresent(_itemName)
    {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(items[_itemName].itemCount >= _quantity, "Not enough stock");

        uint256 requiredEther = items[_itemName].priceInEther * _quantity;
        require(msg.value >= requiredEther * 1 ether, "Not enough Ether sent");

        items[_itemName].itemCount -= _quantity;

        if (items[_itemName].itemCount == 0) {
            items[_itemName].stat = status.notpresent;
        }

        owner.transfer(msg.value);
        emit order(_itemName, msg.value / 1 ether); // Emit paid amount in Ether
    }

    receive() external payable {}
    fallback() external payable {}
}
