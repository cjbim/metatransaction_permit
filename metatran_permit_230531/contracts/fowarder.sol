pragma solidity ^0.8.9;

import "./contracts/access/Ownable.sol";

interface IERC20Permit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GaslessTokenTransfer is Ownable{
    mapping(address => bool) public whitelist; // 토큰 어드레스별로 whitelist 상태를 관리합니다.
    uint256 public whitelistCount; // whitelist에 포함된 주소의 개수를 추적합니다.


    function addToWhitelist_struct(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (!whitelist[addresses[i]]) {
                whitelist[addresses[i]] = true;
                whitelistCount++;
            }
        }
    }
    function addToWhitelist(address addr) public onlyOwner {
        require(!whitelist[addr], "Address is already whitelisted");
        whitelist[addr] = true;
        whitelistCount++;
    }

    function removeFromWhitelist(address addr) public onlyOwner {
        if (whitelist[addr]) {
            delete whitelist[addr];
            whitelistCount--;
        }
    }


    function checkAddressInWhitelist(address addr) public view returns (bool) {
        return whitelist[addr];
    }
    function single_token_transfer(
        address token,
        address sender,
        address receiver,
        uint256 amount,
        uint256 fee,
        uint256 deadline,
        // Permit signature
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Permit
        
        require(whitelist[token], "tokenContract is not whitelisted"); // 화이트리스트 체크
        uint256 check = IERC20Permit(token).balanceOf(sender);
            require(check >= amount+fee, "Not enough Token balance");
       
        IERC20Permit(token).permit(
            sender, 
            address(this),
            amount + fee,
            deadline,
            v,
            r,
            s
        );
        // Send amount to receiver
        IERC20Permit(token).transferFrom(sender, receiver, amount);
        // Take fee - send fee to msg.sender
        IERC20Permit(token).transferFrom(sender, msg.sender, fee);
    }
    function multi_token_transfer(
        address[2] memory token_adds,
        address[2] memory sender_receiver,
        uint256[2] memory amount_fee,
        uint256 deadline,
        // Permit signature
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint8 v2,
        bytes32 r2,
        bytes32 s2
    ) external {
        for (uint8 i = 0; i < token_adds.length; i++) {
            require(whitelist[token_adds[i]], "tokenContract is not whitelisted"); // 화이트리스트 체크
        }
    
        uint256 check = IERC20Permit(token_adds[0]).balanceOf(sender_receiver[0]);
            require(check >= amount_fee[0], "Not enough Token balance");
        uint256 check2 = IERC20Permit(token_adds[1]).balanceOf(sender_receiver[0]);
            require(check2 >= amount_fee[1], "Not enough Token balance");

        
        // Permit
        IERC20Permit(token_adds[0]).permit(
            sender_receiver[0], 
            address(this),
            amount_fee[0],
            deadline,
            v,
            r,
            s
        );
        IERC20Permit(token_adds[1]).permit(
            sender_receiver[0], 
            address(this),
            amount_fee[1],
            deadline,
            v2,
            r2,
            s2
        );
        // Send amount to receiver
        IERC20Permit(token_adds[0]).transferFrom(sender_receiver[0], sender_receiver[1], amount_fee[0]);
        // Take fee - send fee to msg.sender
        IERC20Permit(token_adds[1]).transferFrom(sender_receiver[0], msg.sender, amount_fee[1]);
    }


}