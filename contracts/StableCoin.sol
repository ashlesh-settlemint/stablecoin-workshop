// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ReserveConsumerV3.sol";

contract StableCoin is ERC20, ERC20Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // address _reserveAddress;
    uint8 _decimal;
    uint256 _collateralSupply;

    constructor(string memory name, string memory symbol, uint256 colleateralSupply, address defaultAdmin, address pauser, address minter, address burner, uint8 decimal)
        ERC20(name, symbol)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(BURNER_ROLE, burner);

        _collateralSupply = colleateralSupply;
        _decimal = decimal;
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

    function burnFrom(address from, uint256 amount) public virtual onlyRole(BURNER_ROLE){
     super._burn(from, amount);
    }


    // The following functions are overrides required by Solidity.

    function _mint(address account, uint256 amount) internal virtual override(ERC20) {
        /*  Oracle based check

        if(_reserveAddress != address(0)) {
            ReserveConsumerV3 reserveConsumerInstance = ReserveConsumerV3(_reserveAddress);
            uint256 reserveBalance = uint256(reserveConsumerInstance.getLatestReserve());
            reserveBalance = reserveBalance * (10**(decimals() - reserveConsumerInstance.getDecimals()));

            if(totalSupply() + amount > reserveBalance) {
                revert('Insufficient reserve balance');
            }
        }
        */

       require(totalSupply() + amount < _collateralSupply, "Token supply exceeding the collateral asset supply");
       super._mint(account, amount);
    }

    function updateCollateralSupply(uint256 newCollateralSupply) public {
        _collateralSupply = newCollateralSupply;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
      super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    function decimals() public view override(ERC20) returns (uint8) {
        return _decimal;
    }
}
