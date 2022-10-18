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

function createCustomer(string customerNumber, string password) returns boolean {
    Customer customer = {
        _id: "",
        customerNumber: customerNumber,
        password: password
    };

    var jsonData = customer.toJson();

    mongodb:Error? insert = dbClient->insert(<map<json>>jsonData, "Customer");
    if insert is mongodb:Error {
        io:println("error inserting customer:" + insert.message());
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
    if nextRecord is error{
        io:println(nextRecord.message());
        return ();
    }
    if nextRecord is (){
        return ();
    }

    var customer = nextRecord.value.ensureType(Customer);
    if customer is error {
        io:println(customer.message());
        return ();
    }

    return customer;
}
