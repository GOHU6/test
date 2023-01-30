<?php
    $host = 'postgresqlserverhugomorin.postgres.database.azure.com';
    $dbname = 'postgresqlDatabase_hugo_morin';
    $username = 'psqladmin';
    $password = 'H@Sh1CoR3!';
 
    $dsn = "pgsql:host=$host;port=5432;dbname=$dbname;user=$username;password=$password";
    
    try{
        $conn = new PDO($dsn);
        
        if($conn){
        echo "Connecté à $dbname avec succès!";
        }
    }catch (PDOException $e){
        echo $e->getMessage();
    }
?>