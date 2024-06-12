<?php
// $servername = "localhost"; // Replace with your MySQL server name
// $username = "u538862443_root"; // Replace with your MySQL username
// $password = "Rootpd3#"; // Replace with your MySQL password
// $database = "u538862443_bgam"; // Replace with your MySQL database name

// // Create connection
// $conn = new mysqli($servername, $username, $password, $database);

// // Check connection
// if ($conn->connect_error) {
//     die("Connection failed: " . $conn->connect_error);
// }


$servername = "localhost"; // Replace with your MySQL server name
$username = "root"; // Replace with your MySQL username
$password = "Rootpd3#"; // Replace with your MySQL password
$database = "szabsync"; // Replace with your MySQL database name

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
