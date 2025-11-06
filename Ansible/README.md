create a playgournd enviros to test playbook, playgr snippet created via AI qween3 instryuct local model


before run ansible
create setup on your pc prepare.sh

ansible -i inventory.ini all -m ping
ansible-playbook -i inventory.ini site.yml

curl http://172.30.0.10:8080





ssh ansible@172.30.0.11 'rpm -q mariadb-server'   # (password: ansible)
i have trid to install mariadb with https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/ansible-and-mariadb/installing-mariadb-deb-files-with-ansible

but struggling with package community.mysql when installing
