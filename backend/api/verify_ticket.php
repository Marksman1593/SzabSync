<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to get ticket info

    // Assuming the POST request contains 'ticketID'
    $ticketID = $_POST['ticketID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $ticketID = $conn->real_escape_string($ticketID);

    // Get the ticket from the database
    $sql = "SELECT * FROM tickets WHERE id = $ticketID";
    $ticketResult = $conn->query($sql);

    if ($ticketResult->num_rows > 0) {
        $ticket = $ticketResult->fetch_assoc();

        // Get the event data
        $sql = "SELECT * FROM events WHERE id = " . $ticket['eventID'];
        $eventResult = $conn->query($sql);
        $event = $eventResult->num_rows > 0 ? $eventResult->fetch_assoc() : null;

        // Get the student data
        $sql = "SELECT * FROM students WHERE studentID = " . $ticket['studentID'];
        $studentResult = $conn->query($sql);
        $student = $studentResult->num_rows > 0 ? $studentResult->fetch_assoc() : null;

        echo json_encode(["status" => 200, "ticket" => $ticket, "event" => $event, "student" => $student]);
    } else {
        echo json_encode(["status" => 404, "message" => "Ticket not found."]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>