<?php

    $conn = connectToDB();

    if (isset($_GET["table"])) {
        $selectedTable = $_GET["table"];
        display($conn, $selectedTable);
    }

    // Close connection
    $conn->close();

    function connectToDB(){
        $servername = "localhost";
        $username = "root";
        $password = "passW123";
        $dbname = "colocviu";

        // Create connection
        $conn = mysqli_connect($servername, $username, $password, $dbname);
        // Check connection
        if (!$conn) {
            die("Connection failed: " . mysqli_connect_error());
        }
        return $conn;
    }

    function display($conn, $tableName){
        $sqlQuery = "select * from " . "$tableName";

        displayAll($conn, $sqlQuery, $tableName);

    }

    function displayAll($conn, $query, $tableName){
    $result = $conn->query($query);

    if($result->num_rows > 0){
        // Output data in an HTML table
        echo "<div class='table-container'>";
        echo "<h2 class='table-title'>$tableName Table</h2>";
        echo "<table class='styled-table'>";
        echo "<tr>";

        // Output table headers dynamically
        $row = $result->fetch_assoc();
        foreach ($row as $header => $value) {
            echo "<th>$header</th>";
        }

        echo "</tr>";

        // Output data of each row
        $result->data_seek(0); // Reset result set pointer to the beginning
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            foreach ($row as $value) {
                echo "<td>$value</td>";
            }
            echo "</tr>";
        }

        echo "</table>";
        echo "</div>";
    } else {
        echo "0 results";
    }
}

function displayColumns($conn, $query, $columns){
    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        // Output data in an HTML table
        echo "<div class='table-container'>";
        echo "<table class='styled-table'>";
        echo "<tr>";

        // Output table headers dynamically for the specified columns
        foreach ($columns as $column) {
            echo "<th>$column</th>";
        }

        echo "</tr>";

        // Output data of each row for the specified columns
        while ($row = $result->fetch_assoc()) {
            echo "<tr>";
            foreach ($columns as $column) {
                echo "<td>{$row[$column]}</td>";
            }
            echo "</tr>";
        }

        echo "</table>";
        echo "</div>";

        // Free the result set
        mysqli_free_result($result);
        
        // Check for additional result sets
        while(mysqli_next_result($conn)) {
            if($result = mysqli_store_result($conn)) {
                mysqli_free_result($result);
            }
        }
    } else {
        echo "0 results";
    }
}



?>