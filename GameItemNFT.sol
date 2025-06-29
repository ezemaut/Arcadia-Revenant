// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GameItem1155
 * @dev Contrato para objetos del juego (armas, pociones, ítems).
 * Cada item es un ID distinto, con múltiples unidades posibles.
 */
contract GameItem1155 is ERC1155, Ownable {
    string public name = "ArcadiaGameItems";
    string public symbol = "AGI";

    // Control de minteo solo para el servidor (owner)
    event ItemMinted(address indexed to, uint256 indexed itemId, uint256 amount);
    event ItemBurned(address indexed from, uint256 indexed itemId, uint256 amount);

    constructor(string memory uri) ERC1155(uri) {}

    /**
     * @dev Mint de un ítem. Solo el owner (servidor o reward manager) puede mintear.
     */
    function mint(address to, uint256 itemId, uint256 amount) external onlyOwner {
        _mint(to, itemId, amount, "");
        emit ItemMinted(to, itemId, amount);
    }

    /**
     * @dev Burn de un ítem por el propio jugador.
     */
    function burn(uint256 itemId, uint256 amount) external {
        _burn(msg.sender, itemId, amount);
        emit ItemBurned(msg.sender, itemId, amount);
    }

    /**
     * @dev Burn de ítems desde otra cuenta (por lógica de consumo, penalizaciones, etc).
     */
    function burnFrom(address from, uint256 itemId, uint256 amount) external onlyOwner {
        _burn(from, itemId, amount);
        emit ItemBurned(from, itemId, amount);
    }
}
