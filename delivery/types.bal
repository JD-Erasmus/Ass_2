
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
    string _id; // customer number
    string email;
    string password;
};

public type Order record {
    string _id;
    string orderId;//added this to identify orders
    string Customer ;
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

