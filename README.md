# ReServe_flutter

I. Group member names
| Name | NPM |
|:---:|:---:|
| Alifa Izzatunnisa Elqudsi Prabowo | 2406365212 |
| Evelyne Octaviana Benedicta Aritonang | 2406365282|
| Juansao Fortunio Tandi | 2406365345
| Khayru Rafa Kartajaya | 2406365263
| Maharani Anindya Budiarti | 2406365300
| Shelia Vellicita | 2406453606

II. Application Description

Tired of the same workout routine? Meet ReServe, the app that helps you move, sweat, and explore fitness your way!

ReServe is a smart class booking app designed to make joining fitness sessions simple, fast, and stress-free. With fitness classes like Pilates, Yoga, and Boxing becoming increasingly popular, spots can fill up within minutes. ReServe solves this problem by giving users real-time access to available classes and studios, allowing them to easily find and reserve sessions anytime, anywhere.

The app covers a wide range of fitness experiences from Pilates and Yoga for mindful movement, to Dance and Muay Thai for high-energy workouts, and even Ice Skating for balance, grace, and full-body coordination. Whether it’s your first class or part of your weekly routine, ReServe ensures you spend less time worrying about availability and more time improving your well-being.

For members, ReServe offers convenience, flexibility, and control. You can explore class types, view live schedules, and book instantly. Say goodbye to waiting lists and confusing sign-ups. With ReServe, you can seamlessly manage all your bookings, track upcoming sessions, and discover new ways to stay active all in one website.

For instructors, ReServe provides a smarter system that empowers them to efficiently manage every aspect of their classes. Through the platform, instructors can create new classes, edit existing ones to update details such as the schedule, location, or pricing, and delete classes that are no longer active. This ensures smoother operations, improved organization, and a more streamlined workflow, resulting in happier clients and more time to focus on what matters most: delivering great fitness experiences.

Ultimately, ReServe connects people with the classes they love, making fitness more accessible, organized, and inspiring for everyone.


III. List of Modules

Main (All):<br>
The Main module handles the core setup and access functionalities of the ReServe system. It provides configuration settings and data needed for database seeding, ensuring that initial or sample data is properly inserted for testing, development, or setup purposes. This module also includes the Registration page, which allows users to create their accounts quickly and securely, and the Login page, which verifies user credentials to ensure safe access. Only registered users can interact with the application from browsing and booking classes to managing or creating content ensuring secure and personalized access throughout the system.

User Profile (Juan):<br>
The user profile page displays user information such as their profile picture, username, role, weight, height, and last login time. It serves as a personalized identification hub for each user on the website, showcasing their fitness-related details in a clear and organized layout. Users can also edit and update their profile information, ensuring that their data remains accurate and up to date as they continue their fitness journey with ReServe. 

Landing Page/Home & Search (Maharani):<br>
This Home & Search module serves as the main hub where users can explore and manage available classes. Instructors can create new classes, edit details like price or schedule, and delete classes they own, while members can only view class details through the Details button. Both instructors and members can filter and search for classes by category for easier navigation. This homepage seamlessly connects with all other modules, such as user profiles, product details, and history, to provide a smooth and integrated experience from discovery to reservation.

Blog (Shelia):<br>
The Blog module serves as ReServe's fitness and wellness hub, where users can read and discover valuable content. It features articles, tutorials for classes like yoga and boxing, healthy living tips, and community stories. This space supports users beyond bookings, providing knowledge to help them learn, stay motivated, and get the most out of their wellness journey.

Product Details and Reviews (Alifa):<br>
The Product Details & Review module provides a complete view of each class and supports interactive feedback from members. It displays all class information, including category, class name, instructor, date & time, price, description, location, and picture. When members click the “Details” button, they are directed to this page where they can proceed to checkout (book a class) and use the review system, allowing them to create new reviews, read others’ feedback, edit their own reviews, or delete them. In contrast, instructors only access a read-only product detail page from the Home & Search module, where they can view information about their own classes but cannot book or review. This design clearly separates the roles, ensuring a smooth experience for both instructors and members.

Personal Goals (Khayru):<br>
The Personal Goals module is a personal tracker where users can set and manage their fitness objectives. Users can create a new goal by clicking a date on the calendar, read all their previously made goals, and update a goal's status by clicking a checkbox to visually cross it out as complete.

Checkout Page & History (Evelyn):<br>
The checkout page lets members fill in their booking details, such as participant information and payment method, before confirming their sports session. Once a booking is complete, the History feature allows users to easily view their upcoming class reservations.

IV. User Roles

Member<br>
a. Description:<br>
Users who want to book fitness classes such as Pilates, Yoga, Dance, Boxing, Muay Thai, or Ice Skating for themselves or their group. 

b. Permissions:<br>
- Create, login, and manage their account.
- Search for classes by category
- Check the total payment before confirming a booking
- View booking history
- Cancel reservation

Instructor<br>
a. Description:<br> 
Users with this role can list and manage their fitness classes or studios on ReServe, making them available for Members to discover and book.

b. Permissions:<br>
- Create, login, and manage their account
- Search for classes by category
- Add, edit, and remove classes, including details such as schedule, price, date and time, description, and location.

V. Integration Flow with Web Service

The integration flow between the Flutter application and the ReServe Django web project is as follows:<br>
1. HTTP Communication with Django
The Flutter app uses the http package to send HTTP requests and receive responses from the Django server, primarily targeting endpoints that return data in JSON format (such as class lists, class details, and booking history).

2. Authentication via pbp_django_auth
For login, logout, and registration, the app uses the pbp_django_auth package. This package handles sending user credentials to Django’s authentication endpoints and manages session cookies, ensuring that all subsequent requests are automatically authenticated.

3. Mapping Django Models to Dart Models
Each important Django model (such as class, booking, and user profile) is represented by a corresponding Dart model in the Flutter application. These Dart models handle JSON serialization and deserialization so that the data can be processed safely and consistently on the mobile side.

4. JSON-Based GET/POST Endpoints
On the Django side, dedicated endpoints are provided to receive GET and POST requests from the Flutter app. These endpoints process JSON requests (for example, creating a new booking or updating a profile) and return JSON responses (such as class data or user history), which are then parsed and displayed in the Flutter application.

VI. Links

Figma Link: https://www.figma.com/team_invite/redeem/ofrpzmgVMDOn9n8CVpSdHt
