# creates build objects
mysql -h mysql3.adriver.x -upinto -ppinto pinto -sNe 'select id from builds where has_stack is true order by id asc' | perl -n  -e 'chomp; print "curl --no-proxy 127.0.0.1:3001 -X POST  -d 'build[key_id]=\$_' http://127.0.0.1:3000/builds\n"' | bash

# copies cpanlibs 
find  /home/pinto/.pjam/projects/ -maxdepth 2 -mindepth 2  -name builds -exec find  {} -maxdepth 2  -name cpanlib \; | perl -n -e '@a = split "/"; print "select $a[-2], $a[-4], id from builds where key_id =  $a[-2] ; \n"'  | mysql -hsql3.webdev.x -pjc -ujc jc -sN | perl -n -e '($bid,$pid,$id) = split; print "cp -r /home/pinto/.pjam/projects/$pid/builds/$bid/cpanlib  ~/.jc/builds/$id/ \n"' | bash

# проверка
find  /home/pinto/.pjam/projects/ -maxdepth 2 -mindepth 2  -name builds -exec find  {} -maxdepth 2  -name cpanlib \; | wc -l
find ~/.jc/builds/ -name cpanlib | wc -l

должны выдать одинаковое кол-во файлов


# патч базы 
mysql -h mysql3.adriver.x -upinto -ppinto pinto -sNe 'alter table builds add column has_install_base tinyint(1)'
mysql -h mysql3.adriver.x -upinto -ppinto pinto -sNe  'update builds set has_install_base = 1 where has_stack  = 1'
