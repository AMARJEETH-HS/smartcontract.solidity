// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JustVend {
    enum status {
        present,
        notpresent
    }

    enum machinestat {
        on,
        off
    }

    machinestat public condition;

    struct item {
        uint256 itemCount;
        status stat;
    }

    mapping(string => item) public items;
    string[] public itemNames;

    event order(string name, uint256 value);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        condition = machinestat.on;
    }

    modifier onlyowner() {
        require(owner == msg.sender, "Not the owner");
        _;
    }

    modifier ispresent(string memory _itemName) {
        require(items[_itemName].stat == status.present, "Item not present");
        _;
    }

    modifier costs(uint256 _amount) {
        require(msg.value >= _amount, "Not enough Ether provided");
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

    function listitems(string memory itemname, uint256 noOfItems)
        public
        onlyowner
    {
        // Check manually if the item is already in itemNames[]
        bool alreadyExists = false;

        for (uint256 i = 0; i < itemNames.length; i++) {
            if (keccak256(bytes(itemNames[i])) == keccak256(bytes(itemname))) {
                alreadyExists = true;
                break;
            }
        }

        // If not already in list, push it
        if (!alreadyExists) {
            itemNames.push(itemname);
        }

        items[itemname].itemCount += noOfItems;
        items[itemname].stat = status.present;
    }

    function getitems() public view returns (string[] memory) {
        return itemNames;
    }

    function orderItem(string memory _itemName, uint256 _quantity)
        external
        payable
        machineOn
        ispresent(_itemName)
        costs(_quantity * 2 ether)
    {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(items[_itemName].itemCount >= _quantity, "Not enough stock");

        items[_itemName].itemCount -= _quantity;

        if (items[_itemName].itemCount == 0) {
            items[_itemName].stat = status.notpresent;
        }

        owner.transfer(msg.value);
        emit order(_itemName, msg.value);
    }

    receive() external payable {}

    fallback() external payable {}
}
