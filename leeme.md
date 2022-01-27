# ¿Cómo usan los contratos inteligentes los oráculos?

El uso más popular de los oráculos es el de fuentes de datos. Las plataformas DeFi como AAVE y Synthetix utilizan oráculos Chainlink DATA FEED para obtener precios de activos precisos en tiempo real en sus contratos inteligentes.

Las fuentes de datos de Chainlink son fuentes de datos agregados de muchos operadores de nodos de Chainlink independientes. Cada fuente de datos tiene una dirección en la cadena y funciones que permiten que los contratos lean desde esa dirección. Por ejemplo, el feed ETH / USD.
https://feeds.chain.link/eth-usd


# 1 Invocando un Oráculo

El siguiente código describe un contrato que obtiene el último precio ETH / USD utilizando la red de prueba de Kovan.

Las interfaces facilitan que los contratos de llamada sepan a qué funciones llamar. Por ejemplo, en este caso, AggregatorV3Interface define que todos los agregadores V3 tendrán la función latestRoundData. Podemos ver todas las funciones que expone un agregador V3 en el archivo AggregatorV3Interface en Github.

https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol

Nuestro contrato se inicializa con la dirección hard-coded de la fuente de datos de Kovan para los precios ETH / USD. Luego, en getLatestPrice, utiliza latestRoundData para obtener la ronda más reciente de datos de precios. Estamos interesados en el precio, por lo que la función lo devuelve.

## Ver: PriceConsumerV3.sol

## Prerequisitos: 
- saldo de Eth y token LINK en Kovan
- Kovan Faucet:  https://faucets.chain.link/kovan

## Deploy en Remix
https://remix.ethereum.org/#url=https://docs.chain.link/samples/PriceFeeds/PriceConsumerV3.sol


# 2 Obtener un número aleatorio

La aleatoriedad es muy difícil de generar en blockchains. La razón de esto es que todos los nodos deben llegar a la misma conclusión, formando un consenso. No hay forma de generar números aleatorios de forma nativa en contratos inteligentes, lo cual es lamentable porque pueden ser muy útiles para una amplia gama de aplicaciones. Afortunadamente, Chainlink proporciona Chainlink VRF, también conocido como Chainlink Verifiable Random Function.

## Usando LINK
A cambio de brindar este servicio de generar un número aleatorio, los Oráculos deben ser pagados en LINK. Esto lo paga el contrato que solicita la aleatoriedad y el pago se produce durante la solicitud.

## Estándar de token ERC-677
LINK cumple con el estándar de token ERC-677 y la extensión de ERC-20. Este estándar es lo que permite codificar datos en transferencias de tokens. Esto es parte integral del ciclo de solicitud y recepción. Haga clic aquí para obtener más información sobre ERC-677.

En este ejemplo, crearemos un contrato con un tema de Game of Thrones. Solicitará aleatoriedad a Chainlink VRF, cuyo resultado se transformará en un número entre 1 y 20, imitando el lanzamiento de un dado de 20 caras. Cada número representa una casa de Juego de Tronos. Entonces, si obtienes un 1, se te asigna la casa Targaryan, 2 es Lannister, y así sucesivamente.

Al lanzar los dados, aceptará una variable de dirección para rastrear qué dirección se asigna a cada casa.

## El contrato tendrá las siguientes funciones:

- rollDice: esto envía una solicitud de aleatoriedad a Chainlink VRF
- fulfillRandomness: la función que utiliza Oracle para enviar el resultado a
- house: Para ver la casa asignada de una dirección

## Ver: VRFD20.sol

## Prerequisitos: 
- saldo de Eth y token LINK en Kovan
- Kovan Faucet:  https://faucets.chain.link/kovan
- Fondear el smart contract con 1 LINK
- checkear smartcontract en https://kovan.etherscan.io/


## Deploy en Remix
https://remix.ethereum.org/#url=https://docs.chain.link/samples/VRF/VRFD20.sol


# 3 Requesting API Data

## Solicitar y recibir
El ciclo de solicitud y recepción describe cómo un contrato inteligente solicita datos de un oráculo y recibe la respuesta en una transacción separada.

## Iniciadores
Los iniciadores son los que inician un trabajo dentro de un Oracle. En el caso de un trabajo de solicitud y recepción, el iniciador de RunLog observa la cadena de bloques cuando un contrato inteligente realiza una solicitud. Una vez que detecta una solicitud, inicia el trabajo. Esto ejecuta los adaptadores (tanto centrales como externos) para los que el trabajo está configurado para ejecutarse y, finalmente, devuelve la respuesta al contrato que realizó la solicitud.

## Adaptadores de núcleo
Cada trabajo de Oracle tiene un conjunto configurado de tareas que debe llevar a cabo cuando se ejecuta. Estas tareas están definidas por los adaptadores que admiten. Por ejemplo: si un trabajo necesita realizar una solicitud GET a una API, busque un campo entero sin firmar específico en una respuesta JSON y luego envíelo al contrato solicitante, necesitaría un trabajo con los siguientes adaptadores principales:

HttpGet - Llamar a la API
JsonParse: analiza el JSON y recupera los datos deseados
EthUint256 - Convierta los datos al tipo de datos compatible con Ethereum (uint256)
EthTx: envíe la transacción a la cadena, completando el ciclo.

Veamos un ejemplo real, donde recuperamos 24 volúmenes del par ETH / USD de la API cryptocompare.

## Ver: APIConsumer.sol y OpenWeatherConsumer.sol

##Repasemos lo que está sucediendo aquí:

- Constructor: configure el contrato con la dirección de Oracle, el ID del trabajo y la tarifa LINK que el oráculo cobra por el trabajo

- requestVolumeData: esto crea y envía una solicitud, que incluye el selector de funciones de cumplimiento, al oráculo. Observe cómo agrega los parámetros get, path y times. Estos son leídos por los adaptadores en el trabajo para realizar las tareas correctamente. get es usado por HttpGet, path es usado por JsonParse y times es usado por Multiply.

- fulfill: donde se envía el resultado una vez que se completa el trabajo de Oracle


## Prerequisitos: 
- saldo de Eth y token LINK en Kovan
- Kovan Faucet:  https://faucets.chain.link/kovan
- Fondear el smart contract con 1 LINK

## Deploy en Remix
https://remix.ethereum.org/#url=https://docs.chain.link/samples/APIRequests/APIConsumer.sol