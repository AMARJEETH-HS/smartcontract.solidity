// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ERC20 {
    function totalsupply() external pure returns (uint256 _totalsupply);

    function balanceof(address _addr) external view returns (uint256 _balance);

    function transferto(address _addr, uint256 _value)
        external
        returns (bool);

    function transferfrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 value);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract MyERC20Token is ERC20 {
    string public constant symbol = "UDM";
    string public constant name = "Udaal Mandi";
    uint8 public constant decimals = 18;

    uint256 private constant __totalSupply = 1000000000000000000000000;

    // this mapping is where we store the balances of an address
    mapping(address => uint256) private __balanceOf;

    // This is for the approval function to determine how much an address can spend
    mapping(address => mapping(address => uint256)) private __allowances;

    constructor() {
        __balanceOf[msg.sender] = __totalSupply; //the creator of the contract has the total supply and no one can create tokens
    }

    function totalsupply() public pure override returns (uint256 _totalsupply) {
        return __totalSupply;
    }

    function balanceof(address _addr)
        public
        view
        override
        returns (uint256 _balance)
    {
        return __balanceOf[_addr];
    }

    function transferto(address _addr, uint256 _value)
        public
        override
        returns (bool)
    {
        if (_value > 0 && _value <= __balanceOf[_addr]) {
            __balanceOf[msg.sender] -= _value;
            __balanceOf[_addr] += _value;
            emit Transfer(msg.sender, _addr, _value);
            return true;
        }

        return false;
    }

    function transferfrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        if (
            _value > 0 &&
            __allowances[_from][msg.sender] > 0 &&
            __allowances[_from][msg.sender] >= _value &&
            !isContract(_to)
        ) {
            __balanceOf[_from] -= _value;
            __balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }

        return false;
    }

    function isContract(address _address) public view returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(_address)
        }

        return codeSize > 0;
    }

    function approve(address _addr, uint256 _value)
        external
        override
        returns (bool)
    {
        __allowances[msg.sender][_addr] = _value; // Allow the spender to spend this value
        emit Approval(_addr, msg.sender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        override 
        returns (uint256 remaining)
    {
        return __allowances[_owner][_spender];
    }
}
