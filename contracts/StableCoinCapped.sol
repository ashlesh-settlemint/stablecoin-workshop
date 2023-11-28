// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ReserveConsumerV3.sol";

contract StableCoinCapped is ERC20, ERC20Burnable, ERC20Pausable, ERC20Capped, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address _reserveAddress;

    constructor(string memory name, string memory symbol, uint256 initialSupply, uint256 maxSupply, address defaultAdmin, address pauser, address minter, address reserveAddress)
        ERC20(name, symbol)
        ERC20Capped(maxSupply)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);

        _mint(defaultAdmin, initialSupply);
        _reserveAddress = reserveAddress;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(uint256 amount) public virtual override(ERC20Burnable) onlyRole(BURNER_ROLE){
     super._burn(_msgSender(), amount);
    }


    // The following functions are overrides required by Solidity.

    function _mint(address account, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        if(_reserveAddress != address(0)) {
            ReserveConsumerV3 reserveConsumerInstance = ReserveConsumerV3(_reserveAddress);
            uint256 reserveBalance = uint256(reserveConsumerInstance.getLatestReserve());
            reserveBalance = reserveBalance * (10**(decimals() - reserveConsumerInstance.getDecimals()));

            if(totalSupply() + amount > reserveBalance) {
                revert('Insufficient reserve balance');
            }
        }
        super._mint(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
      super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}
