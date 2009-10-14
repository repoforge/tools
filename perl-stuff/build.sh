#!/bin/sh
set -e

export LANG=C
DATE=$(date "+%a %b %e %Y")
VERSION=`grep  ^Version $1 | cut -d  ' ' -f 2`
OUTPUT=$1.new
NAME=`basename $1 .spec` 
SDIR=/home/cmr/redhat/SOURCES
USER="Christoph Maser <cmr@financial.com>"

grep real_version $1 && exit

URL=$(grep "^Source: *" $1 | sed -e 's/^Source: //' -e "s/%{version}/${VERSION}/")
echo $URL

FILE=`basename $URL`
wget -c $URL -O $SDIR/$FILE 


rpmbuild -bs $1 

egrep "# ExcludeDist.*el4" $1 || mock -r rpmforge-el4-x86_64 -v   --disable-plugin=root_cache /home/cmr/redhat/SRPMS/${NAME}-${VERSION}-1.src.rpm
mock -r rpmforge-el5-x86_64 -v   --disable-plugin=root_cache /home/cmr/redhat/SRPMS/${NAME}-${VERSION}-1.src.rpm && svn diff
