// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./Ownable.sol";

contract Store is Ownable {
    struct Product {
        uint id;
        string name;
        uint quantity;
        uint price;
    }

    Product[] public products;
    mapping(string => bool) public availableProductsNames;

    struct Purchase {
        uint quantity;
        uint256 time;
    }

    // Product id => (Client address => Purchase)
    mapping(uint => mapping(address => Purchase)) public productsPurchases;
    // Product id => array of client addresses
    mapping(uint => address[]) public clientAddressesByProduct;

    event ProductAdded(string, uint, uint);
    event ProductUpdated(uint, uint);
    event ProductBought(address, uint, uint);
    event ProductReturned(address, uint);

    function addNewProduct(string calldata name, uint quantity, uint price) public onlyOwner {
        require(bytes(name).length != 0 && price > 0);
        require(!availableProductsNames[name], "The product is already in the store!");
        
        uint productId = products.length;

        availableProductsNames[name] = true;
        products.push(Product(productId, name, quantity, price));

        emit ProductAdded(name, quantity, price);
    }

    modifier onlyExistingProduct(uint productId) {
        require(productId < products.length, "The product is not existing!");
        _;
    }

    function updateProductQuantity(uint productId, uint quantity) public onlyOwner onlyExistingProduct(productId) {
        products[productId].quantity = quantity;
        
        emit ProductUpdated(productId, quantity);
    }

    function getProducts() public view returns(Product[] memory) {
        return products;
    }

    function buyProduct(uint productId, uint quantity) payable public onlyExistingProduct(productId) {
        require(quantity > 0, "Invalid quantity!");

        address clientAddress = msg.sender;
        
        // Check if the user has already bought the product
        require(productsPurchases[productId][clientAddress].quantity == 0, "You have already bought this product!");

        Product storage currentProduct = products[productId];

        // Check if we have enough quantity from the product
        require(currentProduct.quantity >= quantity, "The product quantity is less than you wanted!");

        uint256 totalPrice = uint256(products[productId].price * quantity);
        require(msg.value == totalPrice, "Please send the exact price of the product multiplied by the quantity you want!");

        // Transfer the ether to the owner of the store
        payable(owner).transfer(totalPrice);

        // Add the new purchase to the state
        productsPurchases[productId][clientAddress] = Purchase(quantity, block.number);
        clientAddressesByProduct[productId].push(clientAddress);

        // Remove the bought quantity from the product
        currentProduct.quantity -= quantity;

        emit ProductBought(clientAddress, productId, quantity);
    }

    function returnProduct(uint productId) public {
        address clientAddress = msg.sender;

        Purchase memory purchase = productsPurchases[productId][clientAddress];
        require(purchase.quantity != 0, "You have not bought this product!");

        uint256 currentTime = block.number;
        require(purchase.time + 100 >= currentTime, "Time for return has expired!");

        // TODO send the money back to the clientAddress
        // clientAddress.transfer()

        products[productId].quantity += purchase.quantity;
        delete productsPurchases[productId][clientAddress];

        // Remove the current client address from client addresses by product
        address[] storage clientAddresses = clientAddressesByProduct[productId];
        uint clientAddressesCount = clientAddresses.length;
        for (uint index = 0; index < clientAddressesCount; index++) {
            if (clientAddresses[index] == clientAddress) {
                clientAddresses[index] = clientAddresses[clientAddressesCount - 1];
                clientAddresses.pop();
                break;
            }
        }

        emit ProductReturned(clientAddress, productId);
    }

    function getClientsAdressesByBoughtProductId(uint productId) public view returns (address[] memory clientAddresses) {
        clientAddresses = clientAddressesByProduct[productId];
    }
}
