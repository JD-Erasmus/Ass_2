
public const TYPE_CREATE_CUSTOMER = 2;
public const TYPE_GET_CUSTOMER = 3;

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
