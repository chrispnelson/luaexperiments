#! /bin/bash

echo "Spam some shit"
sh bash/test.sh $3 $2 $1
sh bash/test2.sh $1 $2 $3
sh bash/test3.sh $3 $1 $2
sh bash/test.sh $1 $1 $1
sh bash/test2.sh $1 $1 $1
sh bash/test3.sh $1 $1 $1
sh bash/test.sh $2 $2 $2
sh bash/test2.sh $2 $2 $2
sh bash/test3.sh $2 $2 $2
sh bash/test.sh $3 $3 $3
sh bash/test2.sh $3 $3 $3
sh bash/test3.sh $3 $3 $3