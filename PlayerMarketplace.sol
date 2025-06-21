// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PlayerMarketplace
 * @dev Marketplace entre jugadores para objetos NFT (GameItemNFT), con custodia de tokens,
 * precios fijos en ESSN y comisión del 2%.
 */
contract PlayerMarketplace is Ownable {
    IERC721 public gameItemNFT;
    IERC20 public essnToken;

    address public feeWallet;
    uint256 public feePercentage = 2;

    struct Listing {
        address seller;
        uint256 price; // en ESSN (sin decimales, deben ser manejados fuera)
    }

    mapping(uint256 => Listing) public listings;

    event ItemListed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event ItemCancelled(address indexed seller, uint256 indexed tokenId);
    event ItemBought(address indexed buyer, uint256 indexed tokenId, uint256 price, uint256 fee);

    constructor(address _gameItemNFT, address _essnToken, address _feeWallet) {
        gameItemNFT = IERC721(_gameItemNFT);
        essnToken = IERC20(_essnToken);
        feeWallet = _feeWallet;
    }

    /**
     * @notice Pone un NFT a la venta por un precio fijo en ESSN.
     */
    function listItem(uint256 tokenId, uint256 price) external {
        require(price > 0, "Precio invalido");
        require(gameItemNFT.ownerOf(tokenId) == msg.sender, "No sos el dueno");
        require(gameItemNFT.isApprovedForAll(msg.sender, address(this)), "Marketplace no aprobado");

        // Transferir el NFT al contrato (custodia)
        gameItemNFT.transferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        emit ItemListed(msg.sender, tokenId, price);
    }

    /**
     * @notice Cancela un listado y devuelve el NFT al vendedor.
     */
    function cancelListing(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller == msg.sender, "No sos el vendedor");

        delete listings[tokenId];
        gameItemNFT.transferFrom(address(this), msg.sender, tokenId);

        emit ItemCancelled(msg.sender, tokenId);
    }

    /**
     * @notice Compra un NFT pagando en ESSN.
     */
    function buyItem(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "El objeto no esta en venta");

        uint256 totalPrice = listing.price;
        uint256 feeAmount = (totalPrice * feePercentage) / 100;
        uint256 sellerAmount = totalPrice - feeAmount;

        // Transferencia de ESSN
        require(essnToken.transferFrom(msg.sender, listing.seller, sellerAmount), "Fallo pago al vendedor");
        require(essnToken.transferFrom(msg.sender, feeWallet, feeAmount), "Fallo pago de comision");

        // Transferencia del NFT
        delete listings[tokenId];
        gameItemNFT.transferFrom(address(this), msg.sender, tokenId);

        emit ItemBought(msg.sender, tokenId, sellerAmount, feeAmount);
    }

    /**
     * @notice Cambia la wallet donde se envía el fee.
     */
    function setFeeWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Direccion invalida");
        feeWallet = newWallet;
    }

    /**
     * @notice Cambia el porcentaje de fee (ej: 2 significa 2%).
     */
    function setFeePercentage(uint256 newFee) external onlyOwner {
        require(newFee <= 10, "Maximo 10%");
        feePercentage = newFee;
    }
}
