# CaterPro UI Refresh

## Design direction
- Premium, clean catering-business dashboard using off-white surfaces, deep navy hero area, restrained green/amber accents, rounded surfaces, clearer spacing and stronger typography.
- Redesigned dashboard with dynamic Cash in Hand, Received, Pending, income, expenses, collection progress and recent works.
- Updated global light/dark theme, input styling, card styling, navigation bar and primary buttons.
- Updated Works, Expenses, Summary and Calendar surface backgrounds to respect the selected theme where those screens used hard-coded white surfaces.
- Fixed Flutter 3.47+ web build compatibility by using `CardThemeData` instead of `CardTheme`.

## Functionality preserved
- Hive local storage for works, expenses and theme setting.
- Work and expense add/edit/delete workflows.
- Paid/Pending toggle and existing calculations.
- PDF/export/backup/restore services and notifications.
- Summary month selection, calendar events and bottom navigation.

## After copying these files into the project
Run:

```bash
flutter pub get
flutter analyze
flutter build web
```

This package is source code; always test the app and verify the GitHub Actions build before relying on the live site.
