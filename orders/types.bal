public const TYPE_CREATE_ORDER = 4;
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



public type Order record {
    string _id;
    string orderId;//added this to identify orders
    string Customer ;
    Item[] items;
};
public type Item record {
    string _id;
    string name;
    int quantity;
    float price;
};