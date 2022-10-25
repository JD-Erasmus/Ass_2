import ballerinax/mongodb;
import ballerina/random;
import ballerina/io;

mongodb:ConnectionConfig mongoConfig = {
    host: "localhost",
    port: 27017,
    username: "dev",
    password: "dev",
    options: {
        sslEnabled: false
    }
};

string database = "Assignment";
mongodb:Client dbClient = check new (mongoConfig, database);

function createOrder(string customerNumber) returns boolean {
    var customer = getCustomer(customerNumber);
    if customer is () {
        return false;
    }

    int|random:Error intInRange = random:createIntInRange(10000000, 20000000);
    if intInRange is random:Error {
        return false;
    }

    Order _order = {
        _id: intInRange.toString(),
        items: [],
        customer: customer
    };

    var jsonData = _order.toJson();

    mongodb:Error? insert = dbClient->insert(<map<json>>jsonData, "Order");
    if insert is mongodb:Error {
        io:println("error inserting order:" + insert.message());
        return false;
    }

    return true;
}

function addItemToOrder(string orderId, string itemId, int quantity) returns boolean {
    var item = getItem(itemId);
    if item is () {
        return false;
    }

    var _order = getOrder(orderId);
    if _order is () {
        return false;
    }

    _order.items.

    var jsonData = _order.toJson();

    mongodb:Error? insert = dbClient->insert(<map<json>>jsonData, "Order");
    if insert is mongodb:Error {
        io:println("error inserting order:" + insert.message());
        return false;
    }

    return true;
}

function getCustomer(string customerNumber) returns Customer? {

    map<json> filter = {customerNumber: customerNumber};

    stream<Customer, error?>|mongodb:DatabaseError|mongodb:ApplicationError|error result = dbClient->find("Customer", database, filter);
    if result is mongodb:Error {
        io:println("error getting customer:" + result.message());
        return ();
    }
    var nextRecord = result.next();
    if nextRecord is error {
        io:println(nextRecord.message());
        return ();
    }
    if nextRecord is () {
        return ();
    }

    var customer = nextRecord.value.ensureType(Customer);
    if customer is error {
        io:println(customer.message());
        return ();
    }

    return customer;
}

function getItem(string itemId) returns Item? {

    map<json> filter = {_id: itemId};

    stream<Item, error?>|mongodb:DatabaseError|mongodb:ApplicationError|error result = dbClient->find("Item", database, filter);
    if result is mongodb:Error {
        io:println("error getting customer:" + result.message());
        return ();
    }
    var nextRecord = result.next();
    if nextRecord is error {
        io:println(nextRecord.message());
        return ();
    }
    if nextRecord is () {
        return ();
    }

    var item = nextRecord.value.ensureType(Item);
    if item is error {
        io:println(item.message());
        return ();
    }

    return item;
}

function getOrder(string orderId) returns Order? {

    map<json> filter = {_id: orderId};

    stream<Order, error?>|mongodb:DatabaseError|mongodb:ApplicationError|error result = dbClient->find("Order", database, filter);
    if result is mongodb:Error {
        io:println("error getting order:" + result.message());
        return ();
    }
    var nextRecord = result.next();
    if nextRecord is error {
        io:println(nextRecord.message());
        return ();
    }
    if nextRecord is () {
        return ();
    }

    var _order = nextRecord.value.ensureType(Order);
    if _order is error {
        io:println(_order.message());
        return ();
    }

    return _order;
}
