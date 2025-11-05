ansible -i inventory.ini all -m ping
ansible-playbook -i inventory.ini site.yml

curl http://172.30.0.10

# RedHat host should have MariaDB server package:
ssh ansible@172.30.0.11 'rpm -q mariadb-server'   # (password: ansible)
