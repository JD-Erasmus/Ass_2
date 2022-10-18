import ballerina/io;
import ballerinax/kafka;
import ballerina/lang.'string;
import ballerina/lang.value;

//-----------------------------------------------------------
//                PRODUCER SETUP
//-----------------------------------------------------------

string[] serviceTopics = [
    "ordering-service",
    "delivery-service",
    "customer-service"
];

kafka:ProducerConfiguration producerConfigs = {
    clientId: "a2-client",
    acks: "all",
    retryCount: 3
};

kafka:Producer producer = check new (kafka:DEFAULT_URL, producerConfigs);

//-----------------------------------------------------------
//                CONSUMER CONFIG
//-----------------------------------------------------------
string[] topics = [
    "a2-client"
];

kafka:ConsumerConfiguration consumerConfig = {
    groupId: "a2-client",
    topics: topics,
    pollingInterval: 1,
    autoCommit: true
};

//-----------------------------------------------------------
//                CONSUMER SERVICE
//-----------------------------------------------------------
listener kafka:Listener consumer = new ("localhost:9092", consumerConfig);

kafka:Service cService = service object {
    remote function onConsumerRecord(kafka:Caller caller, kafka:ConsumerRecord[] records) {
        io:println("msg received");

        // Dispatched set of Kafka records to service, We process each one by one.
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
};

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
    any|error request = value:fromJsonString(message);

    //----------------------------------
    //     CHECK IF ERROR OCCURED
    //----------------------------------
    if request is error {
        io:println(request.detail());
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

        io:println(request.toString());
    }
}

//-----------------------------------------------------------
//         PRODUCE MESSAGE
//-----------------------------------------------------------
function produceMessage(string topic, Request data) {

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

public function main() {
    worker UI_LOOP {
        boolean running = true;
        string input = "";
        int|error option = 0;
        io:println("working");
        while running {

            //--------------------------------
            //    OPTIONS
            //--------------------------------
            io:println("");
            io:println("");
            io:println("1. Test calling ordering service");
            io:println("2. Test calling delivery service");
            io:println("3. Create customer");
            io:println("4. get customer");

            //--------------------------------
            //    HANDLE OPTION INPUT
            //--------------------------------
            input = io:readln("Option: ");
            option = 'int:fromString(input);
            if option is error {
                io:println("\nPlease enter a valid number as an option!\n");
            } else {
                if option == 1 {
                    produceMessage(serviceTopics[0], {userTopic: "a2-client", reqType: 1, data: "hi"});
                }
                if option == 2 {
                    produceMessage(serviceTopics[1], {userTopic: "a2-client", reqType: 1, data: "hi"});
                }
                if option == 3 {
                    produceMessage(serviceTopics[2], {userTopic: "a2-client", reqType: TYPE_CREATE_CUSTOMER, data: ""});
                }
                if option == 4 {
                    produceMessage(serviceTopics[2], {userTopic: "a2-client", reqType: TYPE_GET_CUSTOMER, data: "1234567"});
                }
            }
        }
    }

    error? attach = consumer.attach(cService, "Consumer-Service");
    if attach is error {
        io:println("failed to attach service to listener");
        panic attach;
    } else {
        error? err = consumer.'start();
        if err is error {
            io:println("failed to start kafka listener, exiting: ", err.detail());
        }
    }
}

