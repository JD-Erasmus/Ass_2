deploy services:
    -- bash ./deploy.sh

run client:
    -- cd ./client
    -- bal run

anywhere docker command needs to be run:
    -- newgrp docker

access mongodb
    -- docker exec -it test-mongo bash
    -- mongosh
    -- use Assignment

    Find all customers
    -- db.Customer.find()