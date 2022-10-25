echo "Creating customer service image"
echo "###############################"

cd customers
bal build
cp ./target/bin/customers.jar ./docker/
cd docker
 docker build . -t customer-service:latest

cd ../../

echo "Creating delivery service image"
echo "###############################"

cd delivery
bal build 
cp ./target/bin/delivery.jar ./docker/
cd docker
 docker build . -t delivery-service:latest

cd ../../

echo "Creating orders service image"
echo "###############################"

cd orders
bal build
cp ./target/bin/orders.jar ./docker/
cd docker
 docker build . -t orders-service:latest

echo "Removing old containers"
echo "###############################"

 docker stop customer-service
 docker stop delivery-service
 docker stop orders-service
 docker container prune 


echo "Deploying customer service"
echo "###############################"

 docker run -d --network=host customer-service:latest

echo "Deploying delivery service"
echo "###############################"

 docker run -d --network=host delivery-service:latest

echo "Deploying orders service"
echo "###############################"

 docker run -d --network=host orders-service:latest
