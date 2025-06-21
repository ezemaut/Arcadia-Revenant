
# Arcadia Revenant - Smart Contracts

---

## Contratos incluidos

| Contrato           | Tipo                  | Funcionalidad principal                                                                                     |
|--------------------|-----------------------|-------------------------------------------------------------------------------------------------------------|
| **AvatarNFT**       | ERC721 personalizado  | Representa a los avatares de los jugadores con atributos on-chain: clase, subclase (desbloqueable), y nivel.  |
| **ESSNToken**       | ERC20 estándar        | Token fungible `ESSN` usado como moneda principal del juego para compras, staking, marketplace, y recompensas. |
| **GameItemNFT**     | ERC721 personalizado  | NFT para objetos de juego (armas, armaduras, accesorios, etc.) con atributos on-chain que se asignan al mintear. |
| **MarketplaceCentral** | Contrato de venta fija | Mercado controlado por los desarrolladores para vender objetos base (plantillas), sin NFTs, a precio fijo en ESSN.  |
| **PlayerMarketplace**  | Contrato de mercado P2P | Marketplace entre jugadores para comprar y vender objetos NFT con custodia, precios fijos y comisión del 2%. |

---

## Descripción detallada de cada contrato

### 1. AvatarNFT

**Propósito:**  
Representar al avatar del jugador como un NFT ERC721 que contiene atributos clave on-chain. El avatar es la identidad principal dentro del juego.

**Atributos On-chain:**

- `class`: La clase inicial del avatar, asignada al momento de mintear el NFT. Representa la categoría o rol (ej: guerrero, mago).
- `subclass`: Subclase que puede asignarse solo después de alcanzar nivel 20. Se asigna una única vez para evitar cambios posteriores.
- `level`: Nivel actual del avatar, que puede subir mediante acciones on-chain controladas.
- `subclassSet`: Flag booleano que evita reasignaciones de subclase.

**Funcionalidades clave:**

- `mintAvatar(address to, uint8 classId, string memory tokenURI)`: Solo el dueño del contrato puede mintear nuevos avatares, asignándoles clase y nivel inicial 1. El `tokenURI` contiene metadata descriptiva off-chain.
- `setSubclass(uint256 tokenId, uint8 subclassId)`: Permite asignar la subclase **una sola vez** si el nivel es 20 o superior, asegurando la integridad del desarrollo del avatar.
- `setLevel(uint256 tokenId, uint16 newLevel)`: Permite aumentar el nivel siempre de forma incremental. El contrato evita que se reduzca el nivel.
- `getAvatarData(uint256 tokenId)`: Consulta los atributos del avatar on-chain para interfaces o validaciones.

**Control de acceso:**  
Se usa `onlyOwner` para que solo el backend o autoridad pueda modificar atributos críticos, evitando manipulaciones directas por los jugadores.

---

### 2. ESSNToken

**Propósito:**  
Moneda fungible del ecosistema Arcadia Revenant, basada en ERC20, con suministro fijo y sin inflación.

**Características principales:**

- Total supply fijo definido en la implementación.
- Se usa para todas las transacciones internas:
  - Compra y venta de NFTs en marketplace.
  - Pago de fees y comisiones.
  - Staking para recompensas.
  - Participación en eventos y gobernanza futura.
- Compatible con estándares OpenZeppelin para máxima seguridad y compatibilidad con wallets y DEXs (ej: QuickSwap).

**Uso:**  
Es la moneda base para todas las interacciones económicas dentro del juego y el ecosistema blockchain asociado.

---

### 3. GameItemNFT

## Funcionalidad Principal

- **Mintéo de Objetos Únicos:**  
  Permite crear NFTs de objetos de diferentes tipos (armas, armaduras, libros de habilidad, invocaciones, consumibles, accesorios y skins) con atributos personalizados que se definen off-chain y se envían completos al contrato al momento del mintéo.

- **Almacenamiento On-Chain de Atributos:**  
  Cada objeto guarda en la blockchain sus atributos esenciales y modificadores, como daño físico, defensa mágica, nivel requerido, durabilidad, rareza, y otros, lo que garantiza transparencia, propiedad real y manipulación segura.

- **Sistema de Vinculación (Bind):**  
  Los objetos pueden marcarse como vinculados (`binded`), lo que impide su transferencia posterior, protegiendo la integridad y evitando su venta o cambio si así se desea.

- **Seguridad en Transferencias:**  
  El contrato impide la transferencia de objetos una vez vinculados, asegurando que los items "binded" no puedan salir de la cuenta del usuario.


## Detalles Técnicos

### Enumeración `ItemType`

Define los tipos de objetos gestionados:

- Weapon (arma)
- Armor (armadura)
- SkillBook (libro de habilidades)
- BossSummon (invocación de jefe)
- RepairKit (objeto de reparación)
- SilverGear (equipo de plata)
- Accessory (accesorio)
- Skin (aspecto/skin)

### Estructura `GameItem`

Cada NFT almacena un struct con:

- `itemType`: Tipo de objeto.
- `baseId`: Identificador base del objeto (plantilla).
- `rarity`: Rareza del objeto.
- `levelRequirement`: Nivel mínimo requerido para usarlo.
- `durability`: Durabilidad o cantidad de uso.
- `binded`: Estado de vinculación (true si no se puede transferir).
- Atributos específicos como daño físico y mágico, defensa, velocidad de ataque, habilidades, efectos especiales, usos, entre otros.
- `skinId`: Identificador para skins visuales.

### Funciones principales

- `mintItem(...)`: Mintéo exclusivo para el dueño del contrato. Crea un nuevo NFT con todos los atributos enviados desde fuera de la cadena (off-chain).  
  - Devuelve el `tokenId` del nuevo objeto.
  - Emite evento `ItemMinted`.

- `getItem(tokenId)`: Permite consultar los atributos on-chain de un objeto específico.

- `bindItem(tokenId)`: Permite al propietario marcar un objeto como vinculado para evitar su transferencia posterior. Emite evento `ItemBound`.

- `_beforeTokenTransfer(...)`: Override que previene transferencias si el objeto está vinculado (`binded`).


## Uso e integración

- El backend debe calcular y definir todos los atributos y modificadores off-chain antes de llamar a `mintItem`.
- Los objetos vinculados no pueden ser transferidos ni vendidos hasta ser desvinculados (no implementado en este contrato).
- Integra con marketplace y lógica de juego garantizando la propiedad única y transparente.
- Compatible con wallets y plataformas estándar ERC721.


## Seguridad y consideraciones

- El acceso al minteo está restringido a `onlyOwner` para evitar emisión arbitraria.
- La función de vinculación protege objetos sensibles de ser transferidos o vendidos accidentalmente.
- Se recomienda auditar y probar extensivamente el contrato antes de despliegue en mainnet.


## Eventos

- `ItemMinted(address to, uint256 tokenId, ItemType itemType, uint256 baseId)`  
  Emitido al crear un nuevo objeto NFT.

- `ItemBound(uint256 tokenId)`  
  Emitido al vincular un objeto.
---

### 4. MarketplaceCentral

**Propósito:**  
Mercado controlado por el equipo de desarrollo para vender objetos base (plantillas sin modificadores) a un precio fijo en ESSN.

**Características:**

- No maneja NFTs directamente: vende la "licencia" para recibir un objeto base.
- Los jugadores compran pagando ESSN al contrato.
- El backend escucha eventos de compra (`BaseItemPurchased`) para mintear el NFT personalizado (con modificadores off-chain) y asignarlo al jugador.
- Permite definir y actualizar precios por objeto base.
- Cobra un fee del 2% sobre cada compra para sostenimiento del proyecto.
- Proporciona transparencia y control sobre los objetos base disponibles.

---

### 5. PlayerMarketplace

**Propósito:**  
Mercado P2P entre jugadores para la compra/venta de objetos NFT del juego.

**Características y flujo:**

- Los jugadores listan sus objetos a precio fijo en ESSN.
- Al listar, el NFT se transfiere al contrato (custodia), bloqueando su uso hasta venta o retiro.
- El vendedor puede retirar el NFT antes de la venta, pagando las fees de gas.
- Otro jugador puede comprar el NFT pagando el precio fijado.
- El contrato cobra una comisión fija del 2%, enviando el 98% restante al vendedor.
- Asegura seguridad, custodia y transparencia en las transacciones entre usuarios.
- Evita fraude o uso indebido de objetos mientras están listados.

---

## Flujo general de interacción

1. **Creación de cuenta:**  
   El jugador crea su wallet off-chain que usará para interactuar con el juego.

2. **Minteo de avatar:**  
   El backend mintea un avatar NFT (`AvatarNFT`) para el jugador con clase inicial y nivel 1.

3. **Compra o ganancia de objetos:**  
   El jugador compra objetos base en `MarketplaceCentral` pagando ESSN o gana objetos mediante gameplay (loot).

4. **Asignación de objetos NFT:**  
   El backend mintea objetos con modificadores aplicados en `GameItemNFT` y los asigna al jugador.

5. **Comercio entre jugadores:**  
   Los jugadores pueden listar sus NFTs en `PlayerMarketplace` para venderlos. Otros jugadores pueden comprarlos pagando ESSN.

6. **Evolución del avatar:**  
   El nivel del avatar se actualiza mediante interacciones on-chain autorizadas. Al nivel 20, puede asignarse la subclase.

7. **Gestión off-chain:**  
   La lógica compleja (loot, cálculo de modificadores, experiencia, misiones, efectos visuales) se gestiona fuera de blockchain para optimizar costos y performance.
