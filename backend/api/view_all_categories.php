<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to view all categories

    // Fetch the categories from the database
    $sql = "SELECT * FROM categories";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $categories = [];
        while($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
        echo json_encode(["status" => 200, "message" => "Categories found", "categories" => $categories]);
    } else {
        echo json_encode(["status" => 404, "message" => "No categories found"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only GET requests are allowed."]);
}
?>