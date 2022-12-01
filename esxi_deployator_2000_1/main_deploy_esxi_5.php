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
                opacity: 0.8;
                /* background-image: url(ESXi.jpeg);
                background-size: cover;
                background-repeat:   no-repeat;
                background-position: center center; */
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
                        <!-- <h1><?php echo "This message is from server side." ?></h1> -->

                        
                    </h2>
                </div>
                <div id="collapse_files" class="collapse show" aria-labelledby="files_card" data-parent="#files"
                    style="overflow-y: auto; text-align: center;">
                    <div class="card-body">
                        <a href="http://kanishkkunal.com" 
                        target="popup" 
                        onclick="window.open('csv_tuto.html','popup','width=600,height=600'); return false;">
                            Howto fill .csv template file
                        </a>
                        <a class="btn blue" href="esxi_deploy.csv" target="_blank">DOWNLOAD</a>
                    </div>
                </div>
            </div>
        </div>

        <br>

        <div class="accordion" id="dlcsv" style="width: 67;">
            <div class="card" >
                <div class="card-header" id="files_card">
                    <h2>
                        <center>2 - BUILD</center>
                        <!-- <h1><?php 
                        session_start();
                        echo "This message is from server side." ?></h1> -->
                    </h2>
                </div>
                <div id="collapse_files" class="collapse show" aria-labelledby="files_card" data-parent="#files"
                    style="overflow-y: auto; text-align: center;">
                    <div class="card-body">

                    
                    <form method="post">
                    <p>Selelect Build Version</p>
                      <input type="radio" name="build" value="9484548">
                      <label for="9484548">9484548</label><br>
                      <input type="radio" name="build" value="15160138">
                      <label for="15160138">15160138</label><br>
                      <input type="radio" name="build" value="17867351">
                      <label for="17867351">17867351</label><br>
                      <br>
                      <input type="submit" value="submit"><br> 
                        <br> 
                      </form>
                      
                    <?php
                        if(isset($_POST['build']))
                        {
                        $data=$_POST['build'];                   
                        $fp = fopen('build.txt', 'c');
                        fwrite($fp, $data);
                        fclose($fp);
                        }

                        date_default_timezone_set('Europe/Paris');
                        // echo date('Y-m-d'), "\n";
                        $phpVariable = date('H-i-s__d-m-Y');
                        $_SESSION['date_session'] = $phpVariable;
                    ?>
                    </div>
                </div>
            </div>
        </div>

        <div class="accordion" id="main">
            <div class="card">
                <div class="card-header" id="files_card">
                    <h2>
                        <center>3 - UPLOAD .CSV INPUT FILE</center>
                    </h2>
                </div>
            <div id="collapse_files" class="collapse show" aria-labelledby="files_card" data-parent="#files" style=" overflow-y: auto; text-align: center;">
                <div class="card-body">   
                    
                <form>
                    <div id="dropBox">
                        <p>Select file to upload</p>
                    </div>
                    <input type="file" name="fileInput" id="fileInput" />
                </form>

                <div id="content"></div>
                <!-- <div id="LAUNCH" style="text-align: center;"> -->

                    <script>    
                   
                   var js_date_session = <?php echo json_encode($phpVariable); ?>;
                    console.log(js_date_session); 

                    $(function () {
                            //file input field trigger when the drop box is clicked
                            $("#dropBox").click(function () {
                                $("#fileInput").click();
                            });

                            //prevent browsers from opening the file when its dragged and dropped
                            $(document).on('drop dragover', function (e) {
                                e.preventDefault();
                            });

                            //call a function to handle file upload on select file
                            $('input[type=file]').on('change', fileUpload);
                        });

                        let div = document.createElement('div');
                        div.id = 'content222';
                        // div.innerHTML = '<p>CreateElement example</p>';
                        // document.body.appendChild(div);

                        function fileUpload(event) {
                            //notify user about the file upload status
                            var dataGlobal = 0;
                            $("#dropBox").html(event.target.value + " uploading...");

                            //get selected file
                            files = event.target.files;

                            //form data check the above bullet for what it is  
                            data = new FormData();

                            //file data is presented as an array
                            for (i = 0; i < files.length; i++) {
                                file = files[i];
                                if (!file.type.match('text.*')) {
                                    //check file type
                                    $("#dropBox").html("Please choose a CSV file.");
                                } else if (file.size > 1048576) {
                                    //check file size (in bytes)
                                    $("#dropBox").html("Sorry, your file is too large (>1 MB)");
                                } else {
                                    //append the uploadable file to FormData object
                                    data.append('file', file, file.name);

                                    //create a new XMLHttpRequest
                                    xhr = new XMLHttpRequest();

                                    //post file data for upload
                                    xhr.open('POST', 'upload.php', true);
                                    xhr.send(data);
                                    xhr.onload = function () {
                                        //get response and show the uploading status
                                        response = JSON.parse(xhr.responseText);
                                        if (xhr.status === 200 && response.status == 'ok') {
                                            $("#dropBox").html(file.name + "  . OK");
                                            $.get("uploads/" + js_date_session + "/" + file.name, function(data) {
                                            // start the table	
                                            var html = '<table  style="background-color:#FFFFE0;" class="table table-bordered">';
                                            // split into lines
                                            // html += "<th>ttttttttt</th>";
                                            var rows = data.split("\n");
                                            // parse lines
                                            rows.forEach( function getvalues(ourrow) {
                                                html += "<tr>";
                                                var columns = ourrow.split(",");
                                                html += "<td>" + columns[0] + "</td>";
                                                html += "<td>" + columns[1] + "</td>";
                                                html += "<td>" + columns[2] + "</td>";
                                                html += "<td>" + columns[3] + "</td>";
                                                html += "<td>" + columns[4] + "</td>";
                                                html += "<td>" + columns[5] + "</td>";
                                                html += "<td>" + columns[6] + "</td>";
                                                html += "<td>" + columns[7] + "</td>";
                                                html += "<td>" + columns[8] + "</td>";
                                                html += "<td>" + columns[9] + "</td>";
                                                html += "<td>" + columns[10] + "</td>";
                                                html += "<td>" + columns[11] + "</td>";
                                                html += "<td>" + columns[12] + "</td>";
                                                html += "<td>" + columns[13] + "</td>";
                                                html += "<td>" + columns[14] + "</td>";
                                                html += "<td>" + columns[15] + "</td>";
                                                html += "<td>" + columns[16] + "</td>";
                                                html += "<td>" + columns[17] + "</td>";
                                                html += "<td>" + columns[18] + "</td>";
                                                html += "<td>" + columns[19] + "</td>";
                                                html += "<td>" + columns[20] + "</td>";
                                                html += "<td>" + columns[21] + "</td>";
                                                html += "<td>" + columns[22] + "</td>";
                                                html += "<td>" + columns[23] + "</td>";
                                                html += "</tr>";		
                                            })
                                            // close table
                                            html += "</table>";
                                            // insert into div
                                            $('#dlcsv').append(html);
                                            });

                                            var button = document.createElement("button");
                                            button.setAttribute('style',
                                                'font-size: 20px; cursor: pointer; text-align: center; margin:auto; display:block;'
                                                );
                                        
                                            // div.innerHTML = '<p>< PLEASE WAIT</p>';
                                            // document.body.appendChild(div);

                                            button.innerHTML = '<center>LAUNCH ESXi DEPLOY</center>';
                                            button.onclick = "";
                                            var body = document.getElementsByTagName("body")[0];
                                            body.appendChild(button);
                                            

                                            
                                            // let div = document.createElement('div');
                                            //     div.id = 'content222';
                                                div.innerHTML = '<span class="blink_me"><p><center> ONCE CLICK, PLEASE WAIT</center></p></span>';
                                                document.body.appendChild(div);

                                            button.addEventListener("click", function () {
                                                // alert("did something");
                                                //  $.ajax({
                                                //      type: "POST",
                                                //      url: "upload_run_playbook.php",
                                                //      data: file.name,
                                                //      asynch : true
                                                //     });

                                                function sleep(milliseconds) {
                                                    const date = Date.now();
                                                    let currentDate = null;
                                                    do {
                                                        currentDate = Date.now();
                                                    } while (currentDate - date < milliseconds);
                                                }
                                             

                                                // $("#content").html("This is a message");
                                                console.log(111);
                                                // button.setAttribute("style","visibility:hidden");  

                                                $("#content").append(
                                                    '<div id="iframe"><iframe src="deploy_esxi_run_playbook.php" width="90%" height="10" frameborder="1"></iframe></div>'
                                                    );

                                                  

                                                console.log(222);
                                                sleep(50000);

                                                async function downloadFile() {
                                                    sleep(30000);
                                                    let response = await fetch('uploads/' + js_date_session + '/id.txt');
                                                    if (response.status != 200) {
                                                        sleep(30000);
                                                        console.log(3311);
                                                        throw new Error("Server Error");
                                                    }
                                                    // read response stream as text
                                                    let text_data = await response.text();;
                                                    sleep(30000);
                                                    console.log(3322);
                                                    return text_data;
                                                }

                                                console.log(333);
                                                // $("#waiting").append("<p>Waiting log below ...</p>");
                                                var rrr = downloadFile();
                                                console.log(rrr);

                                                console.log(444);
                                                sleep(30000)
                                                // console.log(555);

                                                rrr.then(value => {
                                                    console.log(666);
                                                    value = value.replace("\n", "")
                                                    console.log(value);
                                                    url_playbook_id = "http://192.175.138.223:448/playbooks/" + value + ".html";
                                                    console.log(url_playbook_id);
                                                    $("#content").append(
                                                        '<div id="iframe"><iframe id="iframeID" src=' + url_playbook_id + ' width="2000" height="1000" frameborder="0"></iframe></div>'
                                                        );
                                                    setInterval(() => {
                                                        console.log("refreshed");
                                                        document.getElementById('iframeID').src = document.getElementById('iframeID').src
                                                    }, 5000);
                                                }).catch(err => {
                                                    console.log(err);
                                                });

                                            });

                                        } else if (response.status == 'type_err') {
                                            $("#dropBox").html("Please choose a CSV file. Click to upload another.");
                                        } else {
                                            $("#dropBox").html("Some problem occured, please try again.");
                                        }


                                    };

                                }
                            }
                        }
            

                    </script>
                    <!-- <span class="blink_me">This Will Blink</span> -->
                </div>
        
                </div>
            </div>
        </div>
    </div>



            <br>

        <div id="contentphp">
            <script>

            </script>
        </div>
    </div>

    </body>

</html>