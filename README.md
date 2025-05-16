# ReLumen: Cultural Experience & Local Guide Platform

ReLumen is a mobile application designed to connect users with authentic cultural experiences and local guides, enhanced by an AI-powered cultural assistant named Luminas. This project aims to make discovering and learning about local traditions and heritage more accessible and engaging.

## About The Project

ReLumen serves as a bridge, fostering connections in the realm of cultural tourism. It has three primary functions:

1.  **Cultural Experience Marketplace:** Connects providers of unique, traditional cultural services (tours, workshops, homestays) with users seeking these authentic experiences. This focuses on smaller, local establishments that offer a genuine taste of local culture.
2.  **Local Guide Network:** Connects tourists with amateur local guides who can offer personalized insights, help discover hidden gems, find great local food, or provide hourly companionship for exploring. Anyone passionate about their local culture can register to become a guide.
3.  **Luminas AI Assistant:** An integrated AI chatbot powered by Google's Gemini API, designed to act as a personal cultural companion. Luminas can answer questions about local culture, history, traditions, tell stories, and make learning interactive.


## Built With

* **Flutter & Dart:** For cross-platform mobile application development.
* **Firebase:**
    * Firebase Authentication: For user sign-up and login.
    * Cloud Firestore: As the NoSQL database for storing user profiles, tour data, guide profiles, etc.
    * Firebase Storage: (Planned for/Used in) Storing images for tours and user profiles.
* **Google Gemini API:** Powering the Luminas AI assistant for cultural information and chat. (Accessed via the `google_generative_ai` Flutter package).

## Key Features (MVP/Prototype)

* **User Authentication:** Email/password registration, login, logout, and persistent auth state.
* **Cultural Tour Discovery:**
    * View a list of available cultural tours fetched from Firestore.
    * View detailed information for each tour.
* **Local Guide Discovery:**
    * View a list of local guide profiles fetched from Firestore, sortable by rating.
    * View detailed information for each guide, including specialties and bio.
* **Luminas AI Assistant:**
    * Interactive chat interface.
    * System prompt to define Luminas's persona as a Vietnamese cultural expert.
    * Direct calls to Gemini API from the Flutter client.
* **User Profile Management:**
    * View user's own profile information (email, role, join date).
    * Edit display name.
    * "Become a Partner" flow: Users can register to become a partner via a simple form, updating their role in Firestore.
    * Partner-specific options on the profile screen (placeholders for "Manage My Tours" and "Manage My Guide Profile").
* **Search Functionality:**
    * Basic text-based search for tours (by title) and guides (by display name).
    * Initial screen suggestions for featured tours and interesting cultural prompts for Luminas.
* **Navigation:** Bottom navigation bar for main sections (Tours, Search, AI, Guides, Profile).
* **Custom Theme:** Light theme with a white and dark orange color scheme.

## Project Structure

The project follows a standard Flutter project structure. Key directories within `lib/` include:

* `main.dart`: Entry point of the application, MaterialApp setup, and Theme.
* `config/`: Contains configuration files like `api_keys.dart` (which should be gitignored).
* `models/`: Contains data model classes (e.g., `tour_model.dart`, `guide_profile_model.dart`, `user_model.dart` - if you created one for Firestore user data).
* `screens/`: Contains UI widget files for different screens of the app (e.g., `login_screen.dart`, `tours_list_screen.dart`, `ai_assistant_screen.dart`, `main_screen.dart` for bottom navigation).
* `widgets/`: For reusable custom widgets.

## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

* **Flutter SDK:** Ensure you have Flutter SDK installed. Refer to the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).
* **Firebase Account:** You will need a Firebase account.
* **Google AI Studio Account:** To obtain a Gemini API Key.
* An Android Emulator or a physical Android device.

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/phacko11/relumen
    cd relumen 
    ```
 

2.  **Install Flutter dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Firebase Project Setup:**
    * Go to the [Firebase Console](https://console.firebase.google.com/) and create a new Firebase project (or use an existing one).
    * **Add an Android App** to your Firebase project:
        * Use `com.example.relumen` as the Android package name (or update it in `android/app/build.gradle.kts` and here if you use a different one).
        * Download the `google-services.json` file provided by Firebase.
        * Place this `google-services.json` file into the `android/app/` directory of your Flutter project.
    * **Enable Authentication:** In the Firebase Console, go to "Authentication" -> "Sign-in method" and enable "Email/Password" provider.
    * **Set up Cloud Firestore:**
        * Go to "Firestore Database" and create a database.
        * Start in **test mode** for initial development (remember to secure your rules before production: `allow read, write: if false;` or proper auth checks).
        * Manually create the following collections and add some sample data as outlined during development:
            * `users` (though user documents are created on signup, you might need to manually set a user's `role` to `partner` for testing partner features initially). Fields: `uid` (String), `email` (String), `displayName` (String), `role` (String - 'user' or 'partner'), `createdAt` (Timestamp), `photoURL` (String, nullable), `partnerInfo` (Map, optional), `becamePartnerAt` (Timestamp, optional).
            * `tours` (Fields: `title`, `description`, `locationName`, `imageUrl`, `price`, `currency`, `duration`, `category`, `hostUid`, `hostName`, `published` (boolean), `createdAt` (Timestamp), `isFeatured` (boolean)).
            * `guide_profile` (Document ID should be the partner's UID. Fields: `uid`, `displayName`, `bio`, `specialties` (Array of Strings), `serviceAreas` (Array of Strings), `hourlyRate` (Number), `currencyRate` (String), `availabilityNotes` (String), `profileImageUrl` (String), `isActive` (boolean), `updatedAt` (Timestamp), `averageRating` (Number), `ratingCount` (Number)).
        * **Create Firestore Indexes:** As you run the app and use sorting/filtering features (e.g., on `GuidesListScreen` or `SearchScreen`), Firestore might output errors in your debug console with links to create necessary composite indexes. Follow those links to create the indexes in the Firebase Console.

4.  **Gemini API Key Setup:**
    * Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and create an API Key.
    * **CRITICAL: Secure your API Key.** In the Google Cloud Console (usually linked from AI Studio or found under "APIs & Services" > "Credentials" for your project), edit the API key and apply:
        * **Application restrictions:** Select "Android apps" and add your app's package name (`com.example.relumen`) and your debug SHA-1 certificate fingerprint.
        * **API restrictions:** Restrict the key to only be able to use the "Generative Language API".
    * **Provide the API Key to the Flutter app:**
        * The recommended way for running is to use the `--dart-define` flag:
            ```sh
            flutter run --dart-define=GEMINI_API_KEY="YOUR_ACTUAL_GEMINI_API_KEY"
            ```
            Replace `"YOUR_ACTUAL_GEMINI_API_KEY"` with your actual key.
        * For local development convenience, you *can* temporarily place your key in `lib/config/api_keys.dart` in the `defaultValue`:
            ```dart
            // lib/config/api_keys.dart
            const String geminiApiKey = String.fromEnvironment(
              'GEMINI_API_KEY',
              defaultValue: 'YOUR_API_KEY_HERE_FOR_LOCAL_TESTING_ONLY', // DO NOT COMMIT THIS
            );
            ```
            **Ensure `lib/config/api_keys.dart` is listed in your `.gitignore` file to prevent committing your key.**

5.  **Run the Application:**
    * Ensure an Android emulator is running or a physical device is connected.
    * Run the app with the API key:
        ```sh
        flutter run --dart-define=GEMINI_API_KEY="YOUR_ACTUAL_GEMINI_API_KEY"
        ```

## Author

* **Relumen - HCMUT-VNU - Viet Nam** 

## License

This project can be open source or private depending on your choice. If open source, choose a license (e.g., MIT License).
Example: Distributed under the MIT License. See `LICENSE` file for more information. (You would need to create a LICENSE file).

## Acknowledgments (Optional)

* Flutter & Dart teams
* Firebase team
* Google AI (for Gemini)
* Any packages you found particularly helpful.
* Inspiration sources.

---
