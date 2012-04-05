#!/bin/bash

rm -rf dist;
mkdir dist;

cp *.php dist;
cp -R inc dist;
cp -R src dist;

mkdir dist/lib;
cd dist/lib;
svn checkout http://moriarty.googlecode.com/svn/trunk/ moriarty ;
git clone https://github.com/semsol/arc2.git arc ;
cd ../..;

cd dist;
tar -czvf vertere_emr_distribution.tar.gz *;
cd ..;
