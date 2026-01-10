# smartkids_project
school project

## Features

### Student Management

This feature allows for the management of student information. The `StudentModel` has the following properties:

- `id`: The unique identifier for the student.
- `name`: The name of the student.
- `grade`: The grade of the student.
- `gender`: The gender of the student.
- `parent`: The parent of the student.
- `active`: A boolean indicating if the student is currently active.

The `StudentService` provides the following methods for interacting with student data:

- `streamStudents()`: Retrieves a real-time stream of all students, ordered by name.
- `addStudent(StudentModel student)`: Adds a new student to the database.
- `updateStudent(StudentModel student)`: Updates an existing student's information.

### Record Management

The `RecordService` is used to manage records for a specific student. It is created with a `studentId` and a `type` of record.

- `streamRecords()`: Retrieves a real-time stream of records for the student, ordered by date in descending order.
- `addRecord(Map<String, dynamic> data)`: Adds a new record for the student.
