// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MarketplaceCentral
 * @dev Venta de objetos base off-chain a precio fijo con pago en ESSN.
 * No guarda objetos ni NFTs, solo recibe pagos y emite eventos para backend.
 */
contract MarketplaceCentral is Ownable {
    IERC20 public essnToken;
    address public feeWallet;
    uint256 public feePercentage = 2;

    // Precio fijo por objeto base
    mapping(uint256 => uint256) public baseItemPrices;

    event BaseItemPriceSet(uint256 indexed baseId, uint256 price);
    event BaseItemPurchased(address indexed buyer, uint256 indexed baseId, uint256 price, uint256 fee);

    constructor(address _essnToken, address _feeWallet) {
        essnToken = IERC20(_essnToken);
        feeWallet = _feeWallet;
    }

    /**
     * @notice Define el precio de un objeto base.
     */
    function setBaseItemPrice(uint256 baseId, uint256 price) external onlyOwner {
        require(price > 0, "Precio invalido");
        baseItemPrices[baseId] = price;
        emit BaseItemPriceSet(baseId, price);
    }

    /**
     * @notice Compra un objeto base pagando en ESSN.
     * El backend debe escuchar el evento y mintear el NFT con atributos off-chain.
     */
    function buyBaseItem(uint256 baseId) external {
        uint256 price = baseItemPrices[baseId];
        require(price > 0, "Objeto no disponible");

        uint256 feeAmount = (price * feePercentage) / 100;
        uint256 sellerAmount = price - feeAmount;

        // Transferir ESSN del comprador a la wallet del propietario (dueño del contrato)
        require(essnToken.transferFrom(msg.sender, owner(), sellerAmount), "Pago al vendedor fallido");
        require(essnToken.transferFrom(msg.sender, feeWallet, feeAmount), "Pago de fee fallido");

        emit BaseItemPurchased(msg.sender, baseId, price, feeAmount);
    }

    /**
     * @notice Cambia la wallet de fee.
     */
    function setFeeWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Direccion invalida");
        feeWallet = newWallet;
    }

    /**
     * @notice Cambia porcentaje de fee (max 10%).
     */
    function setFeePercentage(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Maximo 10%");
        feePercentage = newFee;
    }
}
