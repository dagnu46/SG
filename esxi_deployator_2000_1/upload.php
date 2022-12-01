<?php
if(isset($_POST) == true){

    
    session_start();
    $date_session = $_SESSION['date_session'];

    //generate unique file name
    $fileName = basename($_FILES["file"]["name"]);
    
    //file upload path
    //  $date_session = "555";
    $targetDir = "uploads/$date_session/";
    // $targetDir = "uploads/";
    $targetFilePath = $targetDir . $fileName;


    // purge
    $message=exec("sudo mkdir -p uploads/$date_session");
    // $message=exec("sudo rm $targetDir/*.csv");
    // $message=exec("sudo touch $targetDir/A.txt");
    // 
    $message=exec("sudo chmod 777 uploads/$date_session");

    //allow certain file formats
    $fileType = pathinfo($targetFilePath,PATHINFO_EXTENSION);
    $allowTypes = array('csv');
    
    if(in_array($fileType, $allowTypes)){
        //upload file to server
        if(move_uploaded_file($_FILES["file"]["tmp_name"], $targetFilePath)){
            //insert file data into the database if needed
            //........
            $response['status'] = 'ok';
        }else{
            $response['status'] = 'err';
        }
    }else{
        $response['status'] = 'type_err';
    }
    
    //render response data in JSON format
    echo json_encode($response);
}