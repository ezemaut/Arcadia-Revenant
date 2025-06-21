// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ESSNToken
 * @dev Token fungible principal del juego (ERC20).
 * Se utiliza para compras en el marketplace, recompensas, y economía in-game.
 */
contract ESSNToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 10 ** 18;

    /**
     * @dev Al desplegar el contrato, se asigna todo el supply al owner.
     */
    constructor() ERC20("Essence", "ESSN") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @dev Permite al owner mintear tokens adicionales (recompensas, pruebas, etc).
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Permite a cualquiera quemar sus propios tokens ESSN.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Permite al owner quemar tokens desde otra cuenta (por comisiones u otros usos).
     */
    function burnFrom(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
