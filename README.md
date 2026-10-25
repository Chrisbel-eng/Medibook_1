# MediBook – Hospital Appointment Management System

Java 17 + Swing desktop app with MySQL (JDBC) storage.
Course project: *Object-Oriented Programming Using Java* (B.Tech CSE, Semester 3).

**Team:** Avany Chandran, Chrisbel, Jayaprabha A, Mithra, Rania

---------------------------------------------------------------------------

## 1. What you need

| Requirement | Notes |
|---|---|
| JDK 17 or later | `javac -version` and `java -version` must both work |
| MySQL Server 8.x | running locally (MySQL Workbench is optional, for browsing data) |
| MySQL Connector/J | the JDBC driver `.jar` — see step 3 (or use Maven and skip this) |

## 2. Extract
Unzip `MediBook.zip`. You get a folder `MediBook/` — open a terminal / Command Prompt **inside it**
(the app reads `config/db.properties` relative to this folder).

## 3. Get the JDBC driver
Download `mysql-connector-j-8.4.0.jar` (https://dev.mysql.com/downloads/connector/j/ → *Platform Independent* → ZIP →
copy the `.jar`, or directly from Maven Central:
`https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar`)
and put it in the `lib/` folder. *(Maven users: skip — see section 7.)*

## 4. Configure the database connection
1. Copy `config/db.properties.template` to `config/db.properties`.
2. Edit it and set your MySQL username and password:
   ```
   db.url=jdbc:mysql://localhost:3306/medibook?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
   db.user=root
   db.password=your_mysql_password
   ```
3. Make sure the MySQL service is running. **You don't have to create anything by hand:** on first start the app creates
   the `medibook` database, the three tables and five sample doctors.
   (If you prefer to do it manually, run `sql/schema.sql` in MySQL Workbench first.)

## 5. Build and run

| | Linux / macOS | Windows |
|---|---|---|
| Compile | `./build.sh` | `build.bat` |
| Run | `./run.sh` | `run.bat` |
| Tests (no MySQL needed) | `./run-tests.sh` | `run-tests.bat` |

Without the scripts: 
```
javac -encoding UTF-8 -d out $(find src/main/java -name "*.java")     (copy src/main/resources/schema.sql into out/)
java -cp "out:lib/*" medibook.Main            (use ';' instead of ':' on Windows)
```
IDE users (IntelliJ / Eclipse / NetBeans): create a Java 17 project, mark `src/main/java` as sources,
`src/main/resources` as resources, add the Connector/J jar to the libraries, and run `medibook.Main` with the
**working directory set to the project folder**.

## 6. Using the application

**Sample doctor accounts** (created on first run, password for all: `Doctor@123`)

| Username | Specialization | Hours | Slot |
|---|---|---|---|
| dr.sharma | Cardiology | 09:00–13:00 | 30 min |
| dr.nair | Pediatrics | 10:00–16:00 | 20 min |
| dr.menon | Orthopedics | 14:00–18:00 | 30 min |
| dr.iyer | Dermatology | 09:30–15:30 | 30 min |
| dr.mathew | General Medicine | 08:00–12:00 | 15 min |

**Patients** click *New patient? Register* on the login screen, then log in with their email + password.

| Feature in the abstract | Where in the app |
|---|---|
| User authentication | Login screen (Patient / Doctor selector), PBKDF2-hashed passwords |
| Patient registration | Login → *New patient? Register* |
| Doctor directory | Patient → *Doctors* tab (filter by specialization) |
| Appointment booking | *Doctors* tab → select doctor → *Book appointment…* → pick date + free slot |
| Appointment management | Patient: *My Appointments* (view / cancel). Doctor: *Schedule* (mark completed / no-show / cancel, optional notes) |
| Patient details | Doctor → *Patient details* (only for patients who booked with that doctor) |
| Appointment history | *History* tab for both roles |

To add another doctor (there is no admin screen):
```
java -cp "out:lib/*" medibook.tools.AddDoctor "Dr. Lisa Paul" 42 Female 9876500010 dr.paul Secret123 Neurology 09:00 13:00 30
```

## 7. Optional: Maven
`mvn package` downloads the driver and builds `target/medibook.jar` with `target/lib/`. Run from the project root:
`java -jar target/medibook.jar`.

## 8. Project layout
```
MediBook/
├── config/db.properties.template   copy to db.properties
├── lib/                            put the MySQL driver jar here
├── sql/schema.sql, reset.sql       manual schema / full reset
├── src/main/resources/schema.sql   schema used by the app at start-up
├── src/main/java/medibook/
│   ├── Main.java
│   ├── model/    Person ← Patient, Doctor;  Appointment, AppointmentStatus
│   ├── service/  HospitalSystem (business rules), MediBookException
│   ├── db/       DatabaseManager (all JDBC code)
│   ├── util/     Validator, PasswordUtil, Config
│   ├── ui/       LoginFrame, RegisterDialog, PatientDashboard, DoctorDashboard, BookAppointmentDialog, Async, UiUtil
│   └── tools/    AddDoctor (CLI)
├── src/test/java/                  LogicTest, FlowTest
├── build.sh/.bat  run.sh/.bat  run-tests.sh/.bat  pom.xml
```
**OOP design:** `Person` (abstract) → `Patient`, `Doctor` (inheritance, polymorphic `getRole()`/`getDetails()`);
`Appointment` links them; `HospitalSystem` is the management class (item 5 in the abstract, whose heading was
mis-titled "Problem Description"); `DatabaseManager` is the only class that touches JDBC.

## 9. Business rules implemented
* A slot can only be booked once; booking runs in a DB transaction that locks the doctor row, so two users cannot take the same slot.
* Cancelled slots become free again. A patient cannot hold two scheduled bookings at the same date/time.
* Bookings: today up to 14 days ahead, only on the doctor's slot grid, not in the past.
* Patients may cancel only their own *scheduled, future* appointments.
* Doctors may update only their own *scheduled* appointments; final states (completed / cancelled / no-show) are locked;
  completed / no-show cannot be set for a future date.
* Validation: name, age 1–120, gender, phone (7–15 digits), email format, password ≥ 6 chars with a letter and a digit.
* All SQL uses prepared statements; DB work runs off the Swing event thread (SwingWorker) so the UI never freezes.

## 10. Troubleshooting
| Message | Fix |
|---|---|
| "Configuration file not found" | create `config/db.properties` and start from the project folder |
| "MySQL JDBC driver not found" | put the Connector/J jar in `lib/` |
| "Access denied" | wrong `db.user` / `db.password` |
| "Cannot reach the MySQL server" | start MySQL; check host/port in `db.url` |
| Want a clean start | run `sql/reset.sql`, restart the app |

## 11. Assumptions and limitations
* Doctors work **every day** (no weekly off-days); slots are generated from start/end time and slot length.
* Patients log in with **email**, doctors with a **username** (the abstract doesn't specify).
* The abstract's "update appointment status" is implemented as Completed / No-show / Cancelled.
* There is no admin role; doctors are seeded or added via the `AddDoctor` tool. No password-reset feature.
* Booking window (14 days) and the password rules are my choices, not from the abstract.
