// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XplanDemoToken is ERC20, Ownable {
    mapping(address => bool) private _frozenAccounts;
    mapping(address => uint256) private _lastTransferTime;
    uint256 public transferCooldown = 0;
    string private _tokenUri; // 用于存储元数据URI

    event AccountFrozen(address indexed account, bool frozen);
    event CooldownUpdated(uint256 newCooldown);
    event TokenURIUpdated(string newUri);

    constructor() ERC20("X-plan Demo Token", "XPD") Ownable(msg.sender) {
        // 铸造 10000 * 10^9 个最小单位给部署者
        _mint(msg.sender, 10000 * 10 ** decimals());
        _tokenUri = "https://github.com/tobehost/xplandemo/ERC20/metadata/xpd-token-metadata.json"; // Keep URI but skip mint
    }

    // ================= 元数据管理 =================
    function setTokenURI(string memory newUri) external onlyOwner {
        _tokenUri = newUri;
        emit TokenURIUpdated(newUri);
    }

    function tokenURI() external view returns (string memory) {
        // 返回元数据JSON文件的URL，钱包或浏览器会据此获取图标等信息
        return _tokenUri;
    }

    // ================= 核心管理函数 =================
    function emergencyFreeze(address target, bool freeze) external onlyOwner {
        require(target != address(0), "XPD: cannot freeze zero address");
        _frozenAccounts[target] = freeze;
        emit AccountFrozen(target, freeze);
    }

    function isFrozen(address account) public view returns (bool) {
        return _frozenAccounts[account];
    }

    function setTransferCooldown(uint256 cooldown) external onlyOwner {
        transferCooldown = cooldown;
        emit CooldownUpdated(cooldown);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // ================= 内部转账检查 =================
    function _update(address from, address to, uint256 amount) internal override {
        require(!_frozenAccounts[from], "XPD: sender account is frozen");
        require(!_frozenAccounts[to], "XPD: recipient account is frozen");

        if (transferCooldown > 0 && from != address(0)) {
            require(
                block.timestamp >= _lastTransferTime[from] + transferCooldown,
                "XPD: transfer cooldown active"
            );
            _lastTransferTime[from] = block.timestamp;
        }
        super._update(from, to, amount);
    }
}