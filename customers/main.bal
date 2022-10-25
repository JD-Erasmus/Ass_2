import ballerina/io;
import ballerinax/kafka;
import ballerina/lang.'string;
import ballerina/lang.value;

//-----------------------------------------------------------
//                PRODUCER SETUP
//-----------------------------------------------------------
kafka:ProducerConfiguration producerConfigs = {
    clientId: "customer-service",
    acks: "all",
    retryCount: 3
};

kafka:Producer producer = check new ("localhost:9092", producerConfigs);

//-----------------------------------------------------------
//                CONSUMER CONFIG
//-----------------------------------------------------------
string[] topics = [
    "customer-service"
];

kafka:ConsumerConfiguration consumerConfig = {
    groupId: "customer-service",
    topics: topics,
    pollingInterval: 1,
    autoCommit: true
};

//-----------------------------------------------------------
//                CONSUMER SERVICE
//-----------------------------------------------------------
listener kafka:Listener consumer = new ("localhost:9092", consumerConfig);

service kafka:Service on consumer {
    remote function onConsumerRecord(kafka:Caller caller, kafka:ConsumerRecord[] records) {
        // Dispatched set of Kafka records to service, We process each one by one.
        io:println("msg received");
        foreach var kafkaRecord in records {
            string|() msg = processKafkaRecord(kafkaRecord);
            if msg is string {
                error? _err = processRequest(msg);
            }
            else {
                io:println("ERROR OCCURRED");
            }
        }
    }
}

//-----------------------------------------------------------
//                PROCESS KAFKA RECORDS
//-----------------------------------------------------------
public function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) returns string|() {
    byte[] serializedMsg = <byte[]>kafkaRecord.value;
    string|error msg = 'string:fromBytes(serializedMsg);
    if (msg is string) {
        // Print the retrieved Kafka record.
        io:println("key: ", kafkaRecord.key, " Received Message: ", msg);
        return msg;
    } else {
        io:println("Error occurred while converting message data", msg);
    }
    return "";
}

//-----------------------------------------------------------
//                PROCESS REQUEST
//-----------------------------------------------------------
function processRequest(string message) returns @tainted error? {

    //----------------------------------
    //     CONVERT STRING TO OBJECT
    //----------------------------------
    json|error jsonData = value:fromJsonString(message);
    Request|error request = value:fromJsonWithType(check jsonData, Request);

    //----------------------------------
    //     CHECK IF ERROR OCCURED
    //----------------------------------
    if request is error {
        io:println("Not a request: " + message);
        return request;
    }
    if request is Request {

        //--------------------------------------------
        //     PASS TO REQUEST HANDLER FUNCTIONS
        //--------------------------------------------

        // if request.reqType == TYPE_ADD_COURSE_REQ {
        //     addCourse(request.data);
        //     return;
        // }

        io:println(request.data.toString());

        if request.reqType == 1 {
            produceMessage(request.userTopic, {data: "hi", status: 0});
        }
        if request.reqType == TYPE_CREATE_CUSTOMER {
            handleCreateCustomer(request);
        }
        if request.reqType == TYPE_GET_CUSTOMER {
            handleGetCustomer(request);
        }
    }
}

//-----------------------------------------------------------
//         PRODUCE MESSAGE
//-----------------------------------------------------------
function produceMessage(string topic, Response data) {

    //-----------------------------------------
    //         CONVERT DATA TO JSON
    //-----------------------------------------
    json|error dataJson = data.toJson();

    if dataJson is json {

        //-----------------------------------------
        //         CONVERT JSON TO STRING
        //         THEN TO BYTES
        //-----------------------------------------
        string msg = dataJson.toJsonString();
        byte[] msgBytes = msg.toBytes();

        //-----------------------------------------
        //         SEND MESSAGE
        //-----------------------------------------
        // var sendResult = producer->send(msgBytes, topic);
        var send = producer->send({topic: topic, value: msgBytes});
        if send is kafka:Error {
            io:println("failed to send message: ", send.message());
            return;
        }
        io:println("successfully sent message");
    } else {
        io:println(dataJson.detail());
    }
}

function handleCreateCustomer(Request request) {
    boolean created = createCustomer("1234567", "some-pw");
    if created {
        produceMessage(request.userTopic, {status: 0, data: "ok"});
    } else {
        produceMessage(request.userTopic, {status: 1, data: "user already exists"});
    }
}

function handleGetCustomer(Request request) {
    Customer? customer = getCustomer(request.data);
    if customer is () {
        produceMessage(request.userTopic, {status: 1, data: "failed to get customer"});
        return;
    }
    produceMessage(request.userTopic, {status: 0, data: customer.toJson().toJsonString()});
}
