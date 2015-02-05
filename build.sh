#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://ftp.jp.debian.org/debian/ squeeze main contrib non-free
deb http://ftp.jp.debian.org/debian/ squeeze-lts main contrib non-free
deb http://ftp.jp.debian.org/debian/ squeeze-updates main contrib non-free
EOF

apt-get update

xargs apt-get install -y --force-yes < packages.txt

cd /
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
rm -rf /root/*
rm -rf /tmp/*

apt-get clean


# remove SUID and SGID flags from all binaries
function pruned_find() {
  find / -type d \( -name dev -o -name proc \) -prune -o $@ -print
}

pruned_find -perm /u+s | xargs -r chmod u-s
pruned_find -perm /g+s | xargs -r chmod g-s

# remove non-root ownership of files
chown root:root /var/lib/libuuid

# Install bash 4.3 with CVE-2014-6271
curl -s https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz | tar -xzC /tmp
pushd /tmp/bash-4.3
for i in $(seq -f "%03g" 1 26); do wget https://ftp.gnu.org/gnu/bash/bash-4.3-patches/bash43-$i; patch -p0 < bash43-$i; done
./configure && make && make install
popd
rm -rf /tmp/bash-4.3

# display build summary
set +x
echo -e "\nRemaining suspicious security bits:"
(
  pruned_find ! -user root
  pruned_find -perm /u+s
  pruned_find -perm /g+s
  pruned_find -perm /+t
) | sed -u "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  java -version
  ruby -v
  gem -v
  python -V
) | sed -u "s/^/  /"

echo -e "\nSuccess!"
exit 0
