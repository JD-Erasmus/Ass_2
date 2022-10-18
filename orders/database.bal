import ballerinax/mongodb;
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


//ADD ORDER TO DB 
function createOrder(string orderId ) returns Order? {
    Order Order = {
        _id: "",
        orderId:OrderId,
        customer:customer;
   Item[] items = [_id:_id,name:name,quantity:quantity,price:price];    
    }

    var jsonData = Order.toJson();

    mongodb:Error? insert = dbClient->insert(<map<json>>jsonData, "Order");
    if insert is mongodb:Error {
        io:println("error inserting order:" + insert.message());
        return false;
    }

    return true;
}
//get quanity of item in a store
function getQuantity(string storeNumber) returns Store? {

    map<json> filter = {storeNumber:storeNumber };

    stream<Store, error?>|mongodb:DatabaseError|mongodb:ApplicationError|error result = dbClient->find("Store", database, filter);
    if result is mongodb:Error {
        io:println("error getting store:" + result.message());
        return ();
    }
    var nextRecord = result.next();
    if nextRecord is error{
        io:println(nextRecord.message());
        return ();
    }
    if nextRecord is (){
        return ();
    }

    var store = nextRecord.value.ensureType(Store);
    if store is error {
        io:println(store.message());
        return ();
    }

    return store;
}