<?php

   // $playbid = $_POST['pbid'];
   // print_r($_POST);
   // $csv = $_POST['file.name'];
   // $message=exec("sudo ls -alth /usr/share/nginx/html/isos/");
   // print_r($message);
   // $message=exec("sudo touch /tmp/".$csv);
   // $targetDir = "uploads/";


   // $message=exec("sudo env ANSIBLE_LOAD_CALLBACK_PLUGINS=yes ANSIBLE_STDOUT_CALLBACK=yaml ANSIBLE_LOG_PATH=/usr/share/nginx/html/isos/pl.log /opt/python3/bin/ansible-playbook -vvv /opt/ansible/test/createsite.yaml");
   $message=exec("sudo env ANSIBLE_CALLBACK_PLUGINS=/opt/python3/lib/python3.7/site-packages/ansible_collections/ara/ ANSIBLE_ACTION_PLUGINS=/opt/python3/lib/python3.7/site-packages/ansible_collections/ara/plugins/action/ ANSIBLE_LOOKUP_PLUGINS=/opt/python3/lib/python3.7/site-packages/ansible_collections/ara/plugins/lookup/ ANSIBLE_LOAD_CALLBACK_PLUGINS=yes ANSIBLE_STDOUT_CALLBACK=yaml ANSIBLE_LOG_PATH=/usr/share/nginx/html/isos/playbook.log /opt/python3/bin/ansible-playbook -vvv /usr/share/nginx/html/isos/esxi_deployator_2000/main_deploy_esxi.yaml");
?>