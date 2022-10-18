
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
