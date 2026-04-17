# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project (no CocoaPods/SPM). Open `CareAssistance.xcodeproj` and build with the **CareAssistance** scheme. Multiple white-label schemes exist (Wellbeing, BCI Seguros, PharmaBenefits, VCContigo, CareAssistanceMX, Premedic, ContigoSalud) — each uses compiler flags (`#if CareAssistance`, `#if Wellbeing`, etc.) to switch agreement IDs and branding.

When running inside Xcode, use the `BuildProject` MCP tool or Cmd+B. There are no unit test targets currently configured.

Use `XcodeRefreshCodeIssuesInFile` to quickly validate Swift files without a full build.

## Architecture

### App Flow
`App.swift` → `AppView` → state machine driven by `AppStatusManager`:
- `.loading` → pre-login BrandAccount fetch
- `.onboarding` → sign-in/sign-up flow
- `.selectingEnterprise` → `CompanySelectionView`
- `.signedIn` → `MainTabView` (Home, Programs, Appointments, Profile, More)

### Data Layer
- **Realm** (`RealmSwift`): Local persistence for `User`, `BrandAccounts`, and other models. Views use `@ObservedResults` to observe Realm objects reactively.
- **BrandAccount**: Salesforce-driven dynamic UI config stored in Realm. Records like `"ExamenesAutomatizados"`, `"ExamenesAutomatizadosCustom"`, `"SecMas"`, `"PreLogin"` drive feature configuration. Fields accessed via KVC: `atributoXYC`, `valorXYC`, `nombreElementoXC` (X=section, Y=field).
- **UserDefaults**: Used for session data (`AppStatusManager.credentials`, `selectedEnterprise`) and `ProfileCache` (patient profile fields).

### Network Layer
- `Network` singleton using **Alamofire**. Two base URLs: unauthenticated (`baseUrl`) and authenticated (`baseUrlAuthenticated`).
- Endpoints defined in `Endpoint.swift` with optional `keyDecodingStrategy`. Default is `.convertFromSnakeCase`; Salesforce endpoints (`function_filter`, `get_brand_account_r1`) use `.useDefaultKeys`.
- Network extensions are split by feature: `Network+SignIn.swift`, `Network+Exams.swift`, `Network+AutomatedExams.swift`, `Networkl+FunctionFilter.swift`, etc.
- Key generic services:
  - `function_filter` (POST): Query Salesforce objects with filters and expected fields. Response models: `FunctionFilterResponse` (Account data), `FunctionFilterResponse2` (generic keyed data).
  - `function_flows?api_name=Servicio_Generico__c` (POST): Generic Salesforce action dispatcher. `Campo_1__c` identifies the action; remaining campos carry parameters.

### Feature Structure
Features live under `App/Features/Main/`:
- **Home**: Dashboard with tiles (tasks, appointments, promotions, clinics)
- **Programs**: Programs → Stages → Tasks → Elements (activity completions)
- **MedicalExams**: Three sub-modules:
  - `MedicalExams/` — Doctor-issued exam orders
  - `PatientExams/` — Patient-uploaded exams
  - Automated Exams — Dynamic exam generation flow (10+ step wizard with popups)
- **Prescriptions**: Medical prescriptions viewer
- **Appointments**: Scheduling with professionals

### Automated Exams Module (active development)
Multi-step flow in `AutomatedExamsView.swift` with state-driven popup sequence:
1. Category selection → 2. Disclaimer popup → 3. Loading exams → 4. Select exams → 5. Cart → 6. Confirm personal data → 7. Consent → 8. Confirm email → 9. Cost info → 10. Generate order → 11. Success

Configuration is fully dynamic from BrandAccount Salesforce records:
- `AutomatedExams+Extension.swift`: Parses BrandAccount fields into `AutomatedExamsUIState`
- `AutomatedExamsUIState.swift`: All config structs (popups, buttons, text attributes, colors)
- Uses exact string comparison (switch/case) for Salesforce attribute names, not contains/lowercased

### UI Patterns
- SwiftUI with `NavigationViewCustom` wrapper (custom back button)
- `Color(hex:)` extension for hex color strings from Salesforce
- `parseSalesforceText()` for rendering `**bold**` and `<br>` markup from Salesforce text fields
- Custom fonts: `FiraSans-Regular`, `FiraSans-Bold`, `FiraSans-Medium`, `FiraSans-Italic`
- Image loading via `SDWebImageSwiftUI` (`WebImage`)

## Key Conventions

- **Salesforce field naming**: Properties in Realm models follow `camelCaseC` pattern mapping to `Field_Name__c`. CodingKeys handle the translation.
- **BrandAccount KVC access**: Use `objectSchema[key] != nil` guard before `(self as NSObject).value(forKey:)` to avoid crashes on missing Realm properties.
- **Logging**: Use `print()` with emoji prefixes for console debugging. Network requests/responses for `function_filter`, `function_flows`, and `post_*` endpoints are automatically logged in `Network.swift`.
- **ProfileCache**: `UserDefaults`-based cache for patient profile data (firstName, lastName, birthdate, email, address, gender, rut). Populated via `getProfileFields()` in `ExamsView`, consumed in `AutomatedExamsView`.
- **Date formats**: Salesforce uses `yyyy-MM-dd`; display uses `dd/MM/yyyy`. Convert between them when sending/receiving data.
- **Avoid Combine**: Prefer Swift async/await. Legacy code uses Combine publishers in `AppStatusManager`.

## Design Patterns

### Dynamic UI Configuration from Salesforce (BrandAccount Pattern)
All UI text, colors, fonts, icons, and button states are driven by BrandAccount Salesforce records, not hardcoded. The pattern is:
1. **Realm stores raw records** — `BrandAccounts` fetched at pre-login and post-login
2. **Extension parsers** read fields via KVC (`getAtributo(section:field:)`, `getValor(section:field:)`) and populate typed config structs
3. **Config structs** (`PopupExamConfig`, `CarritoExamConfig`, `TextExamAttributes`, `ButtonExamConfig`) carry the parsed values
4. **Views consume config** with fallback defaults: `attr.font.isEmpty ? "FiraSans-Bold" : attr.font`

Reference implementation: `AutomatedExams+Extension.swift` → `AutomatedExamsUIState.swift` → `AutomatedExamsView.swift`

### Salesforce Attribute Parsing Helpers
Reusable private functions in `AutomatedExams+Extension.swift`:
- `parseTextAttributes("font;size;color;align")` → `TextExamAttributes`
- `parseButton3("texto;colorTexto;colorFondo")` → `ButtonExamConfig`
- `parseButton5("texto;colorTextoActivo;colorTextoInactivo;colorFondoActivo;colorFondoInactivo")` → `ButtonExamConfig` with active/inactive states
- `parseFontName("firasans_bold")` → `"FiraSans-Bold"` (maps Salesforce font names to iOS)

**Important**: Use exact `switch/case` comparison for Salesforce attribute names (like Android does), never `lowercased().contains()`.

### State-Driven Popup Wizard
Multi-step flows use `@State private var showStepX = false` booleans with `if showStepX { PopupView(...) }` overlays inside a `ZStack`. Transitions between steps:
```swift
showCurrentStep = false
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    showNextStep = true
}
```
Each popup receives a typed config struct and closures for `onConfirm`/`onClose`.

### Network Service Pattern
Each feature gets a `Network+Feature.swift` extension with async functions:
```swift
func serviceName(param: String) async -> Result<ResponseType, AppError> {
    let params: [String: Any] = [...]
    return await request(method: .post, endpoint: .endpointName, parameters: params)
}
```
For `function_flows` (generic Salesforce actions), the body uses `Campo_1__c` through `Campo_N__c` where `Campo_1__c` identifies the action.

### Cache-Then-Read Pattern (ProfileCache)
For data needed across multiple views:
1. **Parent view** fetches data from API on appear and saves to `UserDefaults` via a cache struct (`ProfileCache.save(...)`)
2. **Child views** read from cache synchronously (`ProfileCache.firstName`) — no additional API call needed
3. **On update**, the child writes back to cache after successful API update

### BrandAccount Record Naming Convention
Each BrandAccount record serves a specific feature. Fields are organized by "Elemento" (section):
- `nombreElementoXC` — Section name (e.g., `"PopUpConfirmacionDatos"`, `"CustomDetalleCarrito"`)
- `atributoXYC` / `Atributo_X_Y__c` — Field name/key within section X, position Y
- `valorXYC` / `Valor_X_Y__c` — Field value at section X, position Y

Parser iterates `for i in 1...16` per section, reads atributo/valor pairs, and dispatches by attribute name.

### View + Extension Split
Complex views split logic into:
- `FeatureView.swift` — SwiftUI body, UI layout, state management
- `Feature+Extension.swift` — Data parsing, config loading, helper functions

Examples: `ExamsView.swift` + `ExamsView+Extension.swift`, `AutomatedExamsView.swift` + `AutomatedExams+Extension.swift`, `Home+Extension.swift`

### UIState Pattern
Each feature defines a `FeatureUIState` struct that holds all dynamic configuration:
- `ExamUIState` / `ExamsUIState.swift` — For medical exams hub
- `AutomatedExamsUIState` — For automated exams (popups, buttons, categories, validation, cart)
- `HomeUIState` / `HomeUIStateModel.swift` — For home dashboard

These are populated once from BrandAccount on view load, then passed via `@State`/`@Binding` to child views.

### Logging Pattern
Structured console logging with visual separators for debugging:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 [ComponentName] DESCRIPTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   key: "value"
   key2: "value2"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Log at 3 levels: (1) config loading, (2) before service calls with parameters, (3) after service response with parsed values.

## Environment URLs

| Environment | Unauthenticated Base URL | Authenticated Base URL |
|---|---|---|
| DEV | `https://l2zjbkbsw6.execute-api.us-east-1.amazonaws.com/dev-initial-auth/` | `https://hd4kfs9svc.execute-api.us-east-1.amazonaws.com/dev-cognito-auth/` |
| QA | `https://r78t18efk3.execute-api.us-east-1.amazonaws.com/qa-initial-auth/` | `https://a7kcyezhcd.execute-api.us-east-1.amazonaws.com/qa-cognito-auth/` |
| PRD | `https://huudh3ythg.execute-api.us-east-1.amazonaws.com/prd-initial-auth/` | `https://o5neq91ecd.execute-api.us-east-1.amazonaws.com/prd-cognito-auth/` |

Currently hardcoded to PRD in `Network.swift`.

## Clean Transitions (Loading States)

When reloading a list or applying a filter, **ALWAYS** activate loading BEFORE hiding current content. There must never be a frame where neither the list nor the loading spinner is visible.

### Correct order — Starting a load:
1. `isLoading = true` — activate loading/spinner
2. Show the ProgressView (spinner becomes visible)
3. List/content hides (SwiftUI `if isLoading` branch switches)

### Correct order — Receiving the response:
1. Update data (`self.exams = ...`, `self.prescriptions = ...`)
2. `isLoading = false` — spinner hides, list with new data appears

### The anti-pattern to avoid:
Setting content to empty/nil first, then setting loading to true. In that order, SwiftUI renders an intermediate frame with neither list nor spinner — the user sees a white flash. By setting `isLoading = true` first, the spinner is already visible when the list disappears, making the transition seamless.

This applies to every flow that replaces visible content: filters, refresh, back navigation, deletion, pagination, etc.
