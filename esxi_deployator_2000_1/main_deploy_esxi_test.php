<!DOCTYPE html>
<html>

    <head>
        <script src="jquery-ui-1.13.1/jquery.min.js"></script>
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <link rel="stylesheet" href="css/bootstrap-theme.min.css">
        <script src="js/bootstrap.min.js"></script>

        <style>
            #dropBox {
                border: 3px dashed #0087F7;
                border-radius: 5px;
                background: #F3F4F5;
                cursor: pointer;
                margin: auto;
            }

            #dropBox {
                max-width: 800px;
                min-height: 100px;
                max-height: 110px;
                padding: 54px 54px;
                box-sizing: border-box;
            }

            #dropBox p {
                text-align: center;
                margin: auto;
                font-size: 20px;
            }

            #fileInput {
                display: none;

                body {
                    padding: 20px;
                }

                button {
                    margin-top: 20px;
                    line-height: 60px;
                    font-weight: bold;
                    padding: 0 40px;
                    background: salmon;
                    border: none;
                }

                button:hover {
                    background: lightsalmon;
                }
            }

            #faqbox {
                display: none;
            }

            #faqbox:target {
                display: block;
            }


            /* set global font to Open Sans */
            body {
                font-family: 'Open Sans', 'sans-serif';
                /* background-image: url(http://benague.ca/files/pw_pattern.png); */
            }

            /* header */
            h1 {
                color: #55acee;
                text-align: center;
            }

            /* header/copyright link */
            .link {
                text-decoration: none;
                color: #55acee;
                border-bottom: 2px dotted #55acee;
                transition: .3s;
                -webkit-transition: .3s;
                -moz-transition: .3s;
                -o-transition: .3s;
                cursor: url(http://cur.cursors-4u.net/symbols/sym-1/sym46.cur), auto;
            }

            .link:hover {
                color: #2ecc71;
                border-bottom: 2px dotted #2ecc71;
            }

            /* button div */
            #buttons {
                padding-top: 50px;
                text-align: center;
            }

            /* start da css for da buttons */
            .btn {
                border-radius: 5px;
                padding: 15px 25px;
                font-size: 22px;
                text-decoration: none;
                margin: 20px;
                color: #fff;
                position: relative;
                display: inline-block;
            }

            .btn:active {
                transform: translate(0px, 5px);
                -webkit-transform: translate(0px, 5px);
                box-shadow: 0px 1px 0px 0px;
            }

            .blue {
                background-color: #55acee;
                box-shadow: 0px 5px 0px 0px #3C93D5;
            }

            .blue:hover {
                background-color: #6FC6FF;
            }


            /* copyright stuffs.. */
            ppp {
                text-align: center;
                color: #55acee;
                padding-top: 20px;
            }

            .blink_me {
            animation: blinker 1s linear infinite;
            }

            @keyframes blinker {
            50% {
                opacity: 0;
            }
            }   
        </style>


    </head>

    <body>

        <header>
            <nav class="navbar navbar-expand-lg navbar-light bg-light">
                <a class="navbar-brand" href="#">ANSIBLE ESXi DEPLOYATOR 2000</a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavAltMarkup"
                    aria-controls="navbarNavAltMarkup" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNavAltMarkup">
                    <div class="navbar-nav">
                        <a class="nav-item nav-link active" href="#">HOME<span class="sr-only"></span></a>
                        <a class="nav-item nav-link" href="#">ARA</a>
                    </div>
                </div>
            </nav>
        </header>

        <br>

        <div class="accordion" id="dlcsv" style="width: 67;">
            <div class="card" >
                <div class="card-header" id="files_card">
                    <h2>
                        <center>1 - DOWNLOAD .CSV TEMPLATE FILE</center>
                        <h1><?php echo "This message is from server side." ?></h1>
                        <?php

                                function debug_to_console($data) {
                                    $output = $data;
                                    if (is_array($output))
                                        $output = implode(',', $output);

                                    echo "<script>console.log('Debug Objects: " . $output . "' );</script>";
                                }

                            /////////////////////////////////////////////////

                            $pbid = "pbid/id.txt";
                                    $file = fopen( $pbid, "r" ); 
                                    if( $file == false ) {
                                        echo ( "Error in opening file" );
                                        exit();
                                    }
                                    $filesize = filesize( $pbid );
                                    $idd = fread( $file, $filesize );
                                    fclose( $file );
                                    print $idd;
                            /////////////////////////////////////////////////

                            // $pb_status1 = "ttt";
                            debug_to_console("1111111");


                            do {

                                $curl = curl_init();
                                curl_setopt_array($curl, array(
                                CURLOPT_URL => "http://192.175.138.223:443/api/v1/playbooks",
                                CURLOPT_RETURNTRANSFER => true,
                                CURLOPT_TIMEOUT => 30,
                                CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                                CURLOPT_CUSTOMREQUEST => "GET",
                                CURLOPT_HTTPHEADER => array(
                                    "cache-control: no-cache"
                                ),
                                ));
                                $response = curl_exec($curl);
                                $err = curl_error($curl);
                                curl_close($curl);
                                $response = json_decode($response, true); 
                                $pb_status = ($response["results"][0]["status"]);
                                $pb_id = ($response["results"][0]["id"]);
                                echo $pb_status."\n";
                            
                                $pb_status1 = $pb_status;

                                echo "|| $idd || ";
                                echo $idd."\n";
                                debug_to_console("333333333333");

                                sleep(5);
                            }

                            while ($pb_status1 != "completed")
                            // {
                            //     debug_to_console("22222222");

                                // echo  ( "WWWWWHHHHIIIIILLLEEEE"."\n" );
                                   

                                    // if ($pb_status != "completed"){
                                    //     echo  ( "RRRRUUUUNNNNN"."\n" );
                                    //     // break;
                                    // }
                                    // else {
                                    //     echo  ( "CCCOOOMMMPPPLLLLEEETTTEEEDDD"."\n" );

                                    //                 require './PHPMailer/PHPMailer/PHPMailer.php';
                                    //                 require './PHPMailer/PHPMailer/SMTP.php';
                                    //                 require './PHPMailer/PHPMailer/Exception.php';
                                                    
                                    //                 $mail = new PHPMailer\PHPMailer\PHPMailer(true);

                                    //                 try {
                                    //                     //Server settings
                                    //                     $mail->SMTPDebug = PHPMailer\PHPMailer\SMTP::DEBUG_SERVER;                      //Enable verbose debug output
                                    //                     $mail->isSMTP();                                            //Send using SMTP
                                    //                     $mail->Host       = 'smtp-gw.int.world.socgen';                     //Set the SMTP server to send through
                                    //                     $mail->Port       = 25;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

                                    //                     //Recipients
                                    //                     $mail->setFrom('franck.benayou-ext@socgen.com', 'Mailer');
                                    //                     $mail->addAddress('franck.benayou-ext@socgen.com', 'Joe User');     //Add a recipient
                                    //                     $mail->addAddress('ellen@example.com');               //Name is optional
                                    //                     $mail->addReplyTo('info@example.com', 'Information');
                                    //                     $mail->addCC('cc@example.com');
                                    //                     $mail->addBCC('bcc@example.com');

                                    //                     // $mail->addAttachment('/tmp/image.jpg', 'new.jpg');    //Optional name

                                    //                     //Content
                                    //                     $mail->isHTML(true);                                  //Set email format to HTML
                                    //                     $mail->Subject = 'Here is the subject';
                                    //                     $mail->Body    = 'This is the HTML message body <b>in bold!</b>';
                                    //                     $mail->AltBody = 'This is the body in plain text for non-HTML mail clients';

                                    //                     $mail->send();
                                    //                     echo 'Message has been sent';
                                    //                 } catch (Exception $e) {
                                    //                     echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
                                    //                 }

                                    //     break;
                                    // }
                                // // $count1++;
                            // }
                            // echo  ( "nnnnnnnnnnnnnnnnnn"."\n" );
                        ?>
                    </h2>
                </div>
                <div id="collapse_files" class="collapse show" aria-labelledby="files_card" data-parent="#files"
                    style="overflow-y: auto; text-align: center;">
                    <div class="card-body">
                        <a class="btn blue" href="esxi_deploy.csv" target="_blank">DOWNLOAD</a>
                    </div>
                </div>
            </div>
        </div>

        <br>
        <div id="contentphp">
        <h1><?php echo "CONTETNNNNNNNNNNNTTTTTTTTTTT PPHPHPPH." ?></h1>

        </div>
    </div>

    </body>

</html>