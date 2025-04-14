<!DOCTYPE html>
<html>
<head>
    <title>Subiectul 6</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
            color: #333;
            transition: background-color 0.5s;
            background-image: url('background.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        form, button {
            margin-bottom: 10px;
        }

        button {
            padding: 15px;
            margin: 5px;
            cursor: pointer;
            background-color: #292966;
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 15px;
            text-align: center;
            align: center;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #3367d6;
        }

        .button-container {
            display: flex;
            align: center;
            gap: 10px;
            margin: 30px;
        }

        .table-container {
            margin-top: 20px;
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            transition: background-color 0.5s;
        }

        .table-title {
            font-size: 20px;
            margin-bottom: 10px;
        }

        .styled-table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }

        .styled-table th, .styled-table td {
            padding: 8px;
            text-align: left;
            border: 1px solid #dddddd;
        }

        .styled-table th {
            background-color: #f2f2f2;
            padding: 10px;
            text-align: left;
            border: 1px solid #dddddd;
        }

        .styled-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        #homeButton {
            background-color: #bd9c71;
            color: #fff;
            border: none;
            border-radius: 5px;
            padding: 10px;
            margin-bottom: 20px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        #homeButton:hover {
            background-color: #3367d6;
        }
    </style>

</head>

<body>

    <?php 
        include ('queries.php');
    ?>

    <button id="homeButton" onclick="goHome()">Home</button>

    
    <form id="formEx6_3_a" method="get" action="queries.php">
        <label for="quantity1">Enter the value for 3.a (a date):</label>
        <input type="text" id="quantity1" name="quantity1" required>
        <button type="button" onclick="submitForm('ex6_3_a', this.form)">Submit</button>
    </form>

    <form id="formEx6_3_b" method="get" action="queries.php">
        <label for="quantity2">Enter the value for 3.b (an integer):</label>
        <input type="text" id="quantity2" name="quantity2" required>
        <button type="button" onclick="submitForm('ex6_3_b', this.form)">Submit</button>
    </form>

    <form id="formEx6_5_a" method="get" action="queries.php">
        <label for="quantity3">Enter the value for 5.a (a string):</label>
        <input type="text" id="quantity3" name="quantity3" required>
        <button type="button" onclick="submitForm('ex6_5_a', this.form)">Submit</button>
    </form>

    <div class="button-container">
        <button id="displayPersoana" onclick="sendRequest('Persoana')">Display Persoana</button>
        <button id="displayDeviz" onclick="sendRequest('Deviz')">Display Deviz</button>
        <button id="displayPiesa" onclick="sendRequest('Piesa')">Display Piesa</button>
        <button id="displayPiesaDeviz" onclick="sendRequest('Piesa_deviz')">Display Piesa_Deviz</button>
    </div>
    
    <div class="button-container">
        <button id="execute4a" onclick="executeFunction('ex6_4_a')">Execute 4.a</button>
        <button id="execute4b" onclick="executeFunction('ex6_4_b')">Execute 4.b</button>
        <button id="execute5b" onclick="executeFunction('ex6_5_b')">Execute 5.b</button>
        <button id="execute6a" onclick="executeFunction('ex6_6_a')">Execute 6.a</button>
        <button id="execute6b" onclick="executeFunction('ex6_6_b')">Execute 6.b</button>
    </div>

    <a href="/colocviu/Cerinte%20subiect%206.pdf" target="_blank">Instructions</a>    

    <div id="tableContainer"></div>

    <script>
        function sendRequest(tableName) {
            hideElements();
            // Make an AJAX request to the server to fetch and display the table
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    // Display the table content in the 'tableContainer' div
                    document.getElementById("tableContainer").innerHTML = xhr.responseText;
                }
            };

            // Define the PHP file that handles the display logic
            var phpFile = 'dataBase.php';

            // Construct the query string with the selected table name
            var queryString = '?table=' + tableName;

            // Open the asynchronous request
            xhr.open('GET', phpFile + queryString, true);

            // Send the request
            xhr.send();
        }

        function hideElements() {
            var elementsToHide = document.querySelectorAll('form, button:not(#homeButton), a');
            elementsToHide.forEach(function(element) {
                element.style.display = 'none';
            });
        }

        function showElements() {
            var elementsToShow = document.querySelectorAll('form, button, a');
            elementsToShow.forEach(function(element) {
                element.style.display = 'inline-block';
            });
        }

        function executeFunction(functionName) {
            // Make an AJAX request to execute the specified function
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        // Display the result in the 'tableContainer' div
                        document.getElementById("tableContainer").innerHTML = xhr.responseText;
                        hideElements();
                    } else {
                        console.error("Error executing function:", xhr.statusText);
                    }
                }
            };

            // Define the PHP file that handles the execution logic
            var phpFile = 'queries.php';

            // Construct the query string with the selected function name
            var queryString = '?function1=' + functionName;

            // Open the asynchronous request
            xhr.open('GET', phpFile + queryString, true);

            // Send the request
            xhr.send();
        }

        function submitForm(functionName, form) {
            // Get the form data
            const formData = new FormData(form);

            // Make an AJAX request to execute the specified function
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        // Display the result in the 'tableContainer' div
                        document.getElementById("tableContainer").innerHTML = xhr.responseText;
                        hideElements();
                    } else {
                        console.error("Error executing function:", xhr.statusText);
                    }
                }
            };

            // Define the PHP file that handles the execution logic
            const phpFile = 'queries.php';

            // Append the function name to the URL
            const queryString = `?function2=${functionName}&${new URLSearchParams(formData).toString()}`;

            // Open the asynchronous request
            xhr.open('GET', phpFile + queryString, true);

            // Send the request
            xhr.send();
        }



        function goHome() {
            showElements();
            // Reload the page to go back to the main menu
            location.reload();
        }
    

    </script>



</body>
</html>