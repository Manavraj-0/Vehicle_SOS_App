# vehicle_sos_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Installation and Running the Application

To set up and run this Flutter application, follow these steps:

### 1. Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Flutter SDK:** Follow the official Flutter installation guide for your operating system: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   **Android Studio:** Download and install Android Studio, which includes the Android SDK and AVD Manager: [https://developer.android.com/studio](https://developer.android.com/studio)
*   **VS Code (Recommended):** While not strictly required, VS Code with the Flutter extension is highly recommended for development: [https://code.visualstudio.com/](https://code.visualstudio.com/)

### 2. Clone the Repository (if applicable)

If you received this project as a Git repository, clone it to your local machine:

```bash
git clone https://github.com/Manavraj-0/Vehicle_SOS_App.git
cd Vehicle_SOS_App/App/V1/vehicle_sos_app
```

If you received it as a folder, navigate to the project directory:

```bash
```bash
cd vehicle_sos_app
```
```

### 3. Install Dependencies

Navigate to the project root directory (`vehicle_sos_app`) in your terminal and run the following command to fetch all the project dependencies:

```bash
flutter pub get
```

### 4. Running the Application

You can run the application on an Android Virtual Device (AVD), a physical Android device, or a web browser.

#### a. Using an Android Virtual Device (AVD)

Using an AVD is recommended for development as it provides a safe and consistent environment without risking your physical device.

1.  **Open AVD Manager:**
    *   Open Android Studio.
    *   From the Welcome screen, select `More Actions > Virtual Device Manager`.
    *   If you have a project open, go to `Tools > Device Manager`.

2.  **Create a New Virtual Device:**
    *   In the Device Manager, click `Create device`.
    *   Choose a `Phone` hardware profile (e.g., Pixel 6).
    *   Select a system image (e.g., `API 33` or a recent stable version). Download it if necessary.
    *   Click `Next`, give your AVD a name, and click `Finish`.

3.  **Start the AVD:**
    *   In the Device Manager, find your newly created AVD and click the `Launch this AVD in the emulator` button (green triangle).
    *   Wait for the emulator to boot up completely.

4.  **Run the App on AVD:**
    *   Once the AVD is running, open your terminal or VS Code.
    *   Ensure Flutter recognizes your AVD by running:
        ```bash
        flutter devices
        ```
        You should see your AVD listed.
    *   Run the application on the AVD:
        ```bash
        flutter run
        ```
        Flutter will automatically detect and deploy the app to the running emulator.

#### b. Running on a Physical Android Device

1.  **Enable Developer Options and USB Debugging:**
    *   On your Android device, go to `Settings > About phone`.
    *   Tap `Build number` seven times to enable Developer Options.
    *   Go back to `Settings > System > Developer options` (or similar path).
    *   Enable `USB debugging`.

2.  **Connect Device:**
    *   Connect your Android device to your computer using a USB cable.
    *   If prompted on your phone, allow USB debugging.

3.  **Run the App:**
    *   In your terminal, run:
        ```bash
        flutter devices
        ```
        You should see your physical device listed.
    *   Run the application:
        ```bash
        flutter run
        ```

#### c. Running on a Web Browser

To run the application in a web browser (e.g., Chrome):

```bash
flutter run -d chrome
```

This will open the application in a new Chrome browser window.

## Project Structure

*   `lib/main.dart`: Main application entry point and central state management.
*   `lib/ui/`: Contains individual screen widgets (dashboard, alerts, contacts, settings).

## Dependencies

The key dependencies used in this project are listed in `pubspec.yaml`:

*   `flutter_lucide`: For the icon set.
*   `url_launcher`: For launching URLs (phone calls, SMS, maps).
*   `geolocator`: For accessing device location.

These dependencies are automatically installed when you run `flutter pub get`.