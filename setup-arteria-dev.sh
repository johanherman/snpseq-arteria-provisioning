#!/bin/bash

REPOS="arteria-core arteria-packs arteria-runfolder arteria-bcl2fastq arteria-siswrap arteria-checksum"

ARTERIA_SYMLINK=src-arteria

set -e

if ! vagrant plugin list | grep --quiet vagrant-hostmanager; then
  echo "The vagrant package vagrant-hostmanager is missing"
  vagrant plugin install vagrant-hostmanager
else
  echo "vagrant-hostmanager is already installed"
fi

#if [ ! -f 'private_key' ]; then
#  echo 'Generating ssh key for vagrant'
#  ssh-keygen -f private_key -C 'vagrant' -P ''
#fi

#if [ ! -f 'ansible-st2-local/files/arteria_key' ]; then
#  echo "Generating ssh key for arteria"
#  ssh-keygen -f ansible-st2-local/playbooks/files/arteria_user.key -C "arteria" -P ""
#fi

echo "Specify the path to all your local Arteria repos."
echo "If a path without repos is provided then they will be downloaded instead."
read ARTERIA_ROOT

mkdir -p $ARTERIA_ROOT
echo "Symlinking `pwd`/${ARTERIA_SYMLINK} to $ARTERIA_ROOT"
if [ -L "$ARTERIA_SYMLINK" ] ; then
   rm "$ARTERIA_SYMLINK"
fi
ln -s $ARTERIA_ROOT $ARTERIA_SYMLINK

echo "Checking out needed Arteria repos into $ARTERIA_ROOT"
cd $ARTERIA_ROOT

for repo in $REPOS
do
  if [ ! -d "$repo" ] ; then
    git clone https://github.com/arteria-project/$repo
  else
    echo "Repo $repo already exists, skipping."
  fi
done

ansible_version=`ansible --version | head -n 1 | awk '{ print $2 }'`

if [ "$ansible_version" != "2.2.1.0" ]; then
  echo "You are running version '$ansible_version' of Ansible. This version has not been tested."
  exit 1
else
  echo "You are running a version of Ansible that has been tested ($ansible_version)"
fi
