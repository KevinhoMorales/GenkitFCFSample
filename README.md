# GenkitFCFSample

Ejemplo mínimo que conecta una **app iOS (SwiftUI)** con **Firebase Cloud Functions** y **Google Genkit**, usando **Gemini** para generar texto a partir de una idea que escribe el usuario.

---

## ¿Qué hace el proyecto? (visión general)

1. **En el iPhone (SwiftUI)** el usuario escribe una idea (por ejemplo: *“una app de comida con IA”*).
2. La app envía un **POST** en JSON a una **Cloud Function** llamada `generate`.
3. La función ejecuta un **flujo de Genkit** que llama al modelo **Gemini 2.5 Flash** con un prompt fijo del estilo: *“Describe this app idea: …”*.
4. El texto generado vuelve en la respuesta JSON y la app lo muestra en pantalla.

No hay API key de Google en el cliente iOS: la clave vive solo en el servidor (Firebase Secret), que es el patrón recomendado.

---

## Estructura del repositorio

| Carpeta / archivo | Rol |
|-------------------|-----|
| `functions/` | Backend Node.js: Genkit + `@genkit-ai/googleai` + `firebase-functions` v2. |
| `functions/flow.js` | Define el flujo `generateText` y la llamada a `ai.generate` con Gemini. |
| `functions/index.js` | Expone la HTTP function `generate` (POST, body con `text`). |
| `firebase.json` | Indica que el código de Functions está en `functions/`. |
| `GenkitFCFSwift/` | Proyecto Xcode: UI SwiftUI + `AIService` que llama a la URL de la función. |

---

## Flujo técnico paso a paso

### Paso 1 — Usuario escribe en la app

En `ContentView.swift`, el texto se enlaza al `AIViewModel` (`prompt`). Al pulsar **Generar con IA** se llama a `generate()` en segundo plano.

### Paso 2 — La app llama a Cloud Functions

`AIService.swift` construye un `URLRequest`:

- Método: **POST**
- Cabecera: `Content-Type: application/json`
- Cuerpo: `{"text": "<lo que escribió el usuario>"}`

La URL del endpoint está definida en código; si despliegas en **tu** proyecto Firebase, debes cambiarla por la URL de tu función `generate` (región + proyecto + nombre).

### Paso 3 — La función recibe el cuerpo

En `functions/index.js`, la handler lee `req.body.text`. Si no viene nada, usa un valor por defecto (`"una app de comida"`).

### Paso 4 — Genkit ejecuta el flujo

En `functions/flow.js`:

- Se inicializa Genkit con el plugin **Google AI**.
- La API key se lee de `process.env.GOOGLE_API_KEY` (inyectada como **secret** en la función).
- El flujo `generateText` llama a `ai.generate` con el modelo configurado y devuelve `response.text`.

### Paso 5 — Respuesta al cliente

Éxito:

```json
{ "success": true, "data": "<texto generado>" }
```

Error (HTTP 500):

```json
{ "success": false, "error": "..." }
```

La app decodifica esto con `AIGenerateResponse` en `AIResponse.swift` y muestra `data` o un mensaje de error.

---

## Requisitos previos

- **Node.js22** (según `functions/package.json`).
- **Firebase CLI** instalado y sesión iniciada (`firebase login`).
- Proyecto Firebase con **Blaze** (facturación) si vas a usar Cloud Functions en producción.
- **Cuenta / API key de Google AI** (Gemini) para configurar el secret `GOOGLE_API_KEY`.
- **Xcode** reciente para abrir `GenkitFCFSwift/GenkitFCFSwift.xcodeproj`.

---

## Backend: configurar y desplegar (paso a paso)

### 1. Instalar dependencias

Desde la raíz del repo:

```bash
cd functions
npm install
```

### 2. Crear el secret con la API key de Google

Sustituye `TU_API_KEY` por tu clave real:

```bash
firebase functions:secrets:set GOOGLE_API_KEY
```

El CLI te pedirá el valor (o puedes usar variables de entorno según la documentación actual de Firebase).

### 3. Asociar el proyecto Firebase

```bash
cd ..
firebase use --add
```

Elige tu proyecto si aún no hay `.firebaserc` configurado.

### 4. Desplegar solo Functions

```bash
firebase deploy --only functions
```

Al terminar, en la consola de Firebase verás la URL HTTPS de la función `generate` (por región, p. ej. `us-central1`).

### 5. Probar la función con curl (opcional)

```bash
curl -X POST "https://<REGIÓN>-<TU_PROJECT_ID>.cloudfunctions.net/generate" \
  -H "Content-Type: application/json" \
  -d '{"text":"una app de recetas"}'
```

Deberías recibir `success: true` y `data` con texto generado.

---

## App iOS: qué tocar

1. Abre **`GenkitFCFSwift/GenkitFCFSwift.xcodeproj`** en Xcode.
2. En **`AIService.swift`**, actualiza `endpoint` con la URL real de **tu** función `generate` si no usas el mismo proyecto que el del ejemplo.
3. Compila y ejecuta en simulador o dispositivo. La llamada es por **HTTPS**, así que no suele hacer falta ATS extra.

---

## Resumen de archivos clave

- **`functions/index.js`** — HTTP `generate` + manejo de errores + secret `GOOGLE_API_KEY`.
- **`functions/flow.js`** — Flujo Genkit y modelo Gemini.
- **`GenkitFCFSwift/.../AIService.swift`** — Cliente HTTP hacia la función.
- **`GenkitFCFSwift/.../AIViewModel.swift`** — Estado de carga y texto resultado.
- **`GenkitFCFSwift/.../ContentView.swift`** — Interfaz SwiftUI.

---

## Notas

- El prompt en el servidor está en inglés (`Describe this app idea: …`); puedes cambiarlo en `flow.js` si quieres respuestas en otro idioma o un estilo distinto.
- Mantén **rotada y protegida** la `GOOGLE_API_KEY`; no la subas al repositorio ni la pongas en la app iOS.
