echo "POST - Generate files randomly"
for var in {1..10}; do if [ $(curl -X POST -H 'Content-Type: application/json' -d '{"id":"random", "file":"file'$var'"}' $apigateway_url -o /dev/null -s -w "%{http_code}\n") -eq 200 ]; then echo "PASSED"; else break; fi done
echo "GET - Check the files are exist"
for var in {1..10}; do if [ $(curl -X GET -H 'Content-Type: application/json' $(echo $lb_url)random/file$(echo $var) -o /dev/null -s -w "%{http_code}\n") -eq 200 ]; then echo "PASSED"; else break; fi done
echo "DELETE - Delete the files"
for var in {1..10}; do if [ $(curl -X DELETE -H 'Content-Type: application/json' -d '{"id":"random", "file":"file'$var'"}' $lb_url -o /dev/null -s -w "%{http_code}\n") -eq 204 ]; then echo "PASSED"; else break; fi done
echo "GET - Check the files are not exist"
for var in {1..10}; do if [ $(curl -X GET -H 'Content-Type: application/json' $(echo $lb_url)random/file$(echo $var) -o /dev/null -s -w "%{http_code}\n") -eq 400 ]; then echo "PASSED"; else break; fi done
