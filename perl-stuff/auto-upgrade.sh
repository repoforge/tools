#!/bin/sh
set -e

export LANG=C
DATE=$(date "+%a %b %e %Y")
VERSION=$2
OUTPUT=$1.new
NAME=`basename $1 .spec` 
SDIR=/home/cmr/redhat/SOURCES
USER="Christoph Maser <cmr@financial.com>"

URL=$(grep "^Source: *" $1 | sed -e 's/^Source: //' -e "s/%{version}/${VERSION}/g" -e "s/%{name}/${NAME}/g")
FILE=`basename $URL`
wget -c $URL -O $SDIR/$FILE 

grep real_version $1 && exit

sed  -i -e "s/^Version: .*/Version: $2/" \
	 -e "s/^Release: .*/Release: 1%{?dist}/" \
	 -e "/^%changelog/ a\* ${DATE} ${USER} - $VERSION-1\n- Updated to version ${VERSION}.\n" $1 
	
	
echo $URL



rpmbuild -bs $1 

egrep "# ExcludeDist.*el4" $1 || mock -r rpmforge-el4-x86_64 -v   --disable-plugin=root_cache /home/cmr/redhat/SRPMS/${NAME}-${VERSION}-1.src.rpm
mock -r rpmforge-el5-x86_64 -v   --disable-plugin=root_cache /home/cmr/redhat/SRPMS/${NAME}-${VERSION}-1.src.rpm && svn diff
