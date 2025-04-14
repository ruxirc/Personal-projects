<?php

    include ('dataBase.php');

    $conn = connectToDB();


    //ex6_4_a($conn);

    //ex6_4_b($conn);

    if (isset($_POST["quantity3"])) {
        $value = $_POST["quantity3"];
        ex6_5_a($conn, $value);
    }

    if (isset($_GET["function1"])) {
        $functionName = $_GET["function1"];

        switch ($functionName) {
            case 'ex6_4_a':
                ex6_4_a($conn);
                break;
            case 'ex6_4_b':
                ex6_4_b($conn);
                break;
            case 'ex6_5_b':
                ex6_5_b($conn);
                break;
            case 'ex6_6_a':
                ex6_6_a($conn);
                break;
            case 'ex6_6_b':
                ex6_6_b($conn);
                break;
            default:
                echo "Invalid function specified";
                break;
        }
    }

    if (isset($_REQUEST["function2"])) {
        $functionName = $_REQUEST["function2"];
    
        switch ($functionName) {
            case 'ex6_3_a':
                if (isset($_REQUEST["quantity1"])) {
                    $value = $_REQUEST["quantity1"];
                    ex6_3_a($conn, $value);
                }
                break;
            case 'ex6_3_b':
                if (isset($_GET["quantity2"])) {
                    $value = $_GET["quantity2"];
                    ex6_3_b($conn, $value);
                }
                break;
            case 'ex6_5_a':
                if (isset($_REQUEST["quantity3"])) {
                    $value = $_REQUEST["quantity3"];
                    ex6_5_a($conn, $value);
                }
                break;
            default:
                break;
        }
    }

    //ex6_5_b($conn);

    //ex6_6_a($conn);

    //ex6_6_b($conn);

    // Close connection
    $conn->close();

    function ex6_3_a($conn, $value){

        $escapedValue = mysqli_real_escape_string($conn, $value);

        $query = "
            SELECT *
            FROM Deviz
            WHERE data_constatare IS NOT NULL
            AND data_finalizare IS NULL
            AND STR_TO_DATE('01-Sep-2023', '%d-%b-%Y') >= STR_TO_DATE('" . $escapedValue . "', '%d-%b-%Y')
            ORDER BY data_introducere ; " ;

        displayAll($conn, $query, 'Deviz');
    }

    function ex6_3_b($conn, $value){
        $query = "
            select *
            from Piesa
            where cantitate_stoc < " . $value . "
            order by cantitate_stoc asc, descriere desc;";

        displayAll($conn, $query, 'Piesa');
    }

    function ex6_4_a($conn){
        $query = "
            select p.id_p, p.descriere, p.pret_c, pd.pret_r
            from Piesa p join Piesa_Deviz pd on (p.id_p = pd.id_p)
            where p.pret_c > pd.pret_r;";

        $columns = array("id_p", "descriere", "pret_c", "pret_r");

        displayColumns($conn, $query, $columns);
    }

    function ex6_4_b($conn){
        $query = "
            select distinct pd1.id_p as id_p1, pd2.id_p as id_p2
            from Piesa_Deviz pd1 join Piesa_Deviz pd2 on (pd1.id_d = pd2.id_d) and pd1.id_p < pd2.id_p 
            where pd1.cantitate = pd2.cantitate
            order by id_p1, id_p2;";
        
        $columns = array("id_p1", "id_p2");

        displayColumns($conn, $query, $columns);
    }

    function ex6_5_a($conn, $value){
        $query = "
            select *
            from Deviz
            where id_d in (
                select pd.id_d
                from Piesa p join Piesa_Deviz pd on (p.id_p = pd.id_p)
                where lower(descriere) = lower('" . $value . "')
            );";
        
        displayAll($conn, $query, 'Deviz');
        
    }

    function ex6_5_b($conn){
        $query = "
            SELECT p.descriere, p.fabricant
            FROM Piesa p
            WHERE EXISTS (
                SELECT *
                FROM Piesa_Deviz pd
                WHERE p.id_p = pd.id_p
                AND pd.pret_r >= ALL (
                    SELECT pret_r
                    FROM Piesa_Deviz
                )
            );";
        
        $columns = array("descriere", "fabricant");

        displayColumns($conn, $query, $columns);
    }

    function ex6_6_a($conn){
        $query = "
            call CountDevizeByDepanator();";
        
        $columns = array("nume_depanator", "cate_devize");

        displayColumns($conn, $query, $columns);
    }

    function ex6_6_b($conn){
        $query = "
            call GetPiesaSummary();";
        
        $columns = array("descriere", "fabricant", "cantitate_totala");

        displayColumns($conn, $query, $columns);
    }

?>
