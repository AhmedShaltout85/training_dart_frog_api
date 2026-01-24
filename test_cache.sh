#!/bin/bash

echo "=== Testing Lists Cache ==="
echo ""

echo "1. First request (should be MISS):"
curl -s -i http://localhost:8080/api/v1/lists | grep -E "(x-cache|HTTP)"
echo ""

echo "2. Second request (should be HIT):"
curl -s -i http://localhost:8080/api/v1/lists | grep -E "(x-cache|HTTP)"
echo ""

echo "3. Check Redis:"
docker exec -it redis-server redis-cli KEYS "list*"
echo ""

echo "=== Testing Items Cache ==="
echo ""

echo "4. First items request (should be MISS):"
curl -s -i http://localhost:8080/api/v1/items | grep -E "(x-cache|HTTP)"
echo ""

echo "5. Second items request (should be HIT):"
curl -s -i http://localhost:8080/api/v1/items | grep -E "(x-cache|HTTP)"
echo ""

echo "6. Check Redis again:"
docker exec -it redis-server redis-cli KEYS "*"
echo ""

echo "7. View all cached data:"
docker exec -it redis-server redis-cli --raw KEYS "*" | while read key; do
  echo "Key: $key"
  docker exec -it redis-server redis-cli GET "$key"
  echo ""
done