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

## Clean Transitions (Loading States) — Regla de Oro

El loading debe estar **visible hasta que el contenido esté listo en pantalla**. Nunca debe existir un frame donde ni la lista ni el spinner sean visibles (pantalla en blanco). Esta regla aplica a **toda la app**: carga inicial, filtros, refresh, navegación, eliminación, paginación, etc.

### Regla 1: `isLoading = true` desde la declaración (primer frame)
El spinner debe estar visible desde el primer frame que SwiftUI renderiza. Declarar el estado inicial como `true`:
```swift
@State private var isLoading: Bool = true  // ✅ spinner visible desde frame 1
```
**Nunca** declarar `isLoading = false` y activarlo después — eso genera un frame sin spinner ni contenido.

### Regla 2: Orden de entrada / refresh
1. `isLoading = true` — el spinner se muestra (o ya estaba visible)
2. La lista/contenido se oculta (el branch `if isLoading` de SwiftUI cambia)
3. Se llama al servicio de red

```swift
// ✅ Correcto: spinner primero, luego servicio
self.isLoading = true
getRecetas()
```

```swift
// ❌ Incorrecto: vaciar datos primero causa flash blanco
self.prescriptions = nil   // frame sin datos NI spinner
self.isLoading = true
getRecetas()
```

### Regla 3: Orden de respuesta — bloque atómico en `MainActor.run`
Al recibir la respuesta, asignar datos y desactivar loading **en el mismo bloque** `MainActor.run`. SwiftUI agrupa todas las mutaciones de `@State` dentro de un bloque antes de re-renderizar, así el spinner desaparece y la lista aparece en el **mismo frame**:

```swift
await MainActor.run {
    self.isLoading = false          // ← ambos en el mismo bloque
    self.prescriptions = listPres   // ← SwiftUI re-renderiza UNA sola vez
}
```

```swift
// ❌ Incorrecto: bloques separados = dos renders = flash blanco
await MainActor.run { self.isLoading = false }   // render 1: sin spinner, sin datos
await MainActor.run { self.prescriptions = data } // render 2: datos aparecen
```

### Regla 4: Apagar loader explícitamente en caso de error
En el branch `.failure` del `Result`, siempre desactivar `isLoading`. Si no, el spinner queda girando infinitamente:
```swift
case let .failure(error):
    self.isLoading = false   // ✅ siempre apagar, incluso en error
    AppStatusManager.error(error)
```

### Regla 5: Spinner local por vista, no overlay global
Cada vista maneja su propio `@State private var isLoading` con su propio `ProgressView()` inline. **No usar** un spinner global/overlay compartido — los servicios paralelos de otras vistas pueden apagarlo prematuramente.

### Regla 6: Servicios paralelos o parseo pesado
Si una vista llama múltiples servicios en paralelo, tomar control manual del loader:
- No desactivar `isLoading` en cada respuesta individual
- Esperar a que **todos** los servicios terminen antes de hacer `isLoading = false`
- Si hay parseo pesado post-respuesta, mantener el spinner activo hasta que el parseo termine

```swift
// ✅ Ejemplo con múltiples servicios
async let result1 = Network.shared.getRecetas(...)
async let result2 = Network.shared.getExams(...)
let (recetas, exams) = await (result1, result2)

await MainActor.run {
    self.prescriptions = recetas
    self.exams = exams
    self.isLoading = false   // ← al final, cuando TODO está listo
}
```

### Estructura del body — triple branch obligatorio
Toda vista con datos remotos debe seguir esta estructura `if/else if/else`:
```swift
if isLoading {
    ProgressView()                    // Branch A: spinner
} else if !items.isEmpty {
    ScrollView { ForEach(items) ... } // Branch B: lista con datos
} else {
    // Empty state inline              // Branch C: sin datos
}
```

### Referencias canónicas en iOS
- `PrescriptionsView.swift` — Recetas médicas (lista con filtros)
- `ExamsView.swift` — Órdenes de exámenes
- `ProgramsView.swift` — Programas

### Resumen visual

| Momento | Estado | Lo que ve el usuario |
|---------|--------|---------------------|
| Primer frame | `isLoading = true` (declaración) | Spinner |
| Durante carga | `isLoading = true` | Spinner |
| Respuesta OK | datos + `isLoading = false` (atómico) | Lista aparece, spinner desaparece — mismo frame |
| Respuesta error | `isLoading = false` (atómico) | Empty state o error |
| Filtro/refresh | `isLoading = true` → servicio | Spinner reemplaza lista vieja — sin flash |

## Empty State Pattern

Every view that displays data **must** include its own inline empty state to avoid blank screens. Do NOT create a reusable component — each view defines its empty state locally. Two structures are allowed:

### Structure 1: Icon + Title + Description
```swift
VStack(spacing: 12) {
    Spacer()
    Image(systemName: "doc.text.magnifyingglass")
        .font(.system(size: 50, weight: .light))
        .foregroundColor(Color(.systemGray3))
    Text("Título principal")
        .font(Font.custom("FiraSans-Bold", size: 19))
        .foregroundColor(Color(hex: "#5B6770"))
    Text("Descripción secundaria explicativa")
        .font(Font.custom("FiraSans-Regular", size: 15))
        .foregroundColor(Color(hex: "#C4C4C4"))
        .multilineTextAlignment(.center)
    Spacer()
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

### Structure 2: Icon + Text (without description)
```swift
VStack(spacing: 12) {
    Spacer()
    Image(systemName: "folder")
        .font(.system(size: 50, weight: .light))
        .foregroundColor(Color(.systemGray3))
    Text("Mensaje informativo")
        .font(Font.custom("FiraSans-Regular", size: 15))
        .foregroundColor(Color(hex: "#C4C4C4"))
        .multilineTextAlignment(.center)
    Spacer()
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

### Rules
- Show the empty state only when `!isLoading && items.isEmpty` — never during loading.
- Each view chooses the SF Symbol icon that mejor represente su contenido.
- Textos y mensajes deben ser descriptivos y en español.
