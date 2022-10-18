public const TYPE_CREATE_CUSTOMER = 2;
public const TYPE_GET_CUSTOMER = 3;

public type RequestT record {
    string userTopic;
    int reqType;
    string data;
};

//----------------------------
//     REQUEST OBJECT
//----------------------------
public type Request record {
    string userTopic;
    int reqType;
    string data;
};

//----------------------------
//     RESPONSE OBJECT
//----------------------------
public type Response record {
    int status;
    string data;
};

//----------------------------
//     DB OBJECTS
//----------------------------
public type Store record {
    string _id;
    string name;
    Item[] items;
};

public type Item record {
    string _id;
    string name;
    int quantity;
    float price;
};

public type Customer record {
    string _id;
    string customerNumber;
    string password;
};

public type Order record {
    string _id;
    Customer customer;
    Item[] items;
};

public type Delivery record {
    string _id;
    string orderId;
    DeliveryItem[] items;
};

public type DeliveryItem record {
    string itemId;
    string name;
    DeliveryStoreDetails[] stores;
};

public type DeliveryStoreDetails record {
    string storeId;
    int quantity;
};
