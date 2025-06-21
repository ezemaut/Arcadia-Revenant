// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AvatarNFT
 * @dev NFT que representa un avatar con clase, subclase y nivel.
 * La subclase puede asignarse solo una vez y solo si el nivel >= 20.
 * La clase y nivel se asignan/modifican por funciones controladas.
 */
contract AvatarNFT is ERC721URIStorage, Ownable {

    struct AvatarData {
        uint8 class;       // Clase fija al minteo
        uint8 subclass;    // Subclase, 0 = no asignada
        uint16 level;      // Nivel actual
        bool subclassSet;  // Flag para controlar que solo se asigna una vez
    }

    // TokenID => AvatarData
    mapping(uint256 => AvatarData) private _avatarData;

    uint256 private _nextTokenId;

    constructor() ERC721("ArcadiaRevenant Avatar", "ARV") {}

    /**
     * @notice Mintea un nuevo avatar con clase y nivel inicial 1.
     * @param to Dirección que recibirá el NFT.
     * @param classId Identificador de clase.
     * @param tokenURI URI con metadatos del avatar.
     */
    function mintAvatar(address to, uint8 classId, string memory tokenURI) external onlyOwner returns (uint256) {
        require(classId > 0, "Clase invalida");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        _avatarData[tokenId] = AvatarData({
            class: classId,
            subclass: 0,
            level: 1,
            subclassSet: false
        });

        return tokenId;
    }

    /**
     * @notice Permite asignar la subclase si cumple condiciones.
     * @param tokenId ID del avatar.
     * @param subclassId ID de la subclase a asignar.
     */
    function setSubclass(uint256 tokenId, uint8 subclassId) external onlyOwner {
        AvatarData storage avatar = _avatarData[tokenId];
        require(_exists(tokenId), "Avatar no existe");
        require(!avatar.subclassSet, "Subclase ya asignada");
        require(avatar.level >= 20, "Nivel insuficiente para subclase");
        require(subclassId > 0, "Subclase invalida");

        avatar.subclass = subclassId;
        avatar.subclassSet = true;
    }

    /**
     * @notice Permite actualizar el nivel del avatar.
     * @param tokenId ID del avatar.
     * @param newLevel Nuevo nivel (debe ser mayor que el actual).
     */
    function setLevel(uint256 tokenId, uint16 newLevel) external onlyOwner {
        AvatarData storage avatar = _avatarData[tokenId];
        require(_exists(tokenId), "Avatar no existe");
        require(newLevel > avatar.level, "Nuevo nivel debe ser mayor");

        avatar.level = newLevel;
    }

    /**
     * @notice Obtiene los datos on-chain del avatar.
     * @param tokenId ID del avatar.
     */
    function getAvatarData(uint256 tokenId) external view returns (uint8 classId, uint8 subclassId, uint16 level, bool subclassSet) {
        require(_exists(tokenId), "Avatar no existe");
        AvatarData memory avatar = _avatarData[tokenId];
        return (avatar.class, avatar.subclass, avatar.level, avatar.subclassSet);
    }
}
