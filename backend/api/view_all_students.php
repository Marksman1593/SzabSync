<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to view all students

    // Get all students from the database
    $sql = "SELECT * FROM students";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $students = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode(["status" => 200, "students" => $students]);
    } else {
        echo json_encode(["status" => 404, "message" => "No students found."]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only GET requests are allowed."]);
}
?>