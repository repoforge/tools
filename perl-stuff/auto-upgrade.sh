#!/bin/sh
set -e

if [ -f ~/.rpmforge-config ] 
then
	. ~/.rpmforge-config
else
	echo "Create a file ~/.rpmforge-config with values for TOPDIR, SDIR, USER, MOCKCFG, MOCKRES"
	exit 1	
fi

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` spec-file version-number"
  exit 1
fi


export LANG=C
DATE=$(date "+%a %b %e %Y")
VERSION=$2
RPMVERSION=`grep  ^Version: $1 | cut -d  ' ' -f 2`
OUTPUT=$1.new
NAME=`basename $1 .spec` 


URL=$(grep "^Source: *" $1 | sed -e 's/^Source: //' -e "s/%{version}/${VERSION}/g" -e "s/%{name}/${NAME}/g")
FILE=`basename $URL`

wget -c $URL -O $SDIR/$FILE 

grep real_version $1 && exit

if [ -n "$3" ];then
 release="${3}"
else
 release="1"
fi

if [ $VERSION != $RPMVERSION ]
then
	sed  -i -e "s/^Version: .*/Version: $2/" \
		 -e "s/^Release: .*/Release: ${release}%{?dist}/" \
		 -e "/^%changelog/ a\* ${DATE} ${USER} - $VERSION-1\n- Updated to version ${VERSION}.\n" $1 
fi	
	
echo $URL



rpmbuild --define "_topdir $TOPDIR" -bs $1 

mock -v --resultdir=$MOCKRES  --configdir=$MOCKCFG -r rpmforge-el5-x86_64 --disable-plugin=root_cache  $TOPDIR/SRPMS/${NAME}-${VERSION}-${release}.src.rpm

echo "svn commit -m  \"Updated to version ${VERSION}.\""

