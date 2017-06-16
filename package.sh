#!/bin/sh

rm -rf dist
rm -f iccc.deb

mkdir -p dist/usr/bin
mkdir -p dist/usr/share/iccc
mkdir -p dist/usr/share/applications

zip -9 -r dist/usr/share/iccc/iccc.love *.lua assets

cp -r DEBIAN dist/

cp iccc dist/usr/bin

cp icon.png dist/usr/share/iccc
cp iccc.desktop dist/usr/share/applications

dpkg-deb -b dist iccc.deb
