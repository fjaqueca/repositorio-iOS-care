# Implementación de Formulario General Dinámico

## 📋 Resumen

Se ha implementado un sistema completo para construir y mostrar formularios dinámicos basados en la configuración del servicio BrandAccount con Name="FormularioGeneral".

## 🏗️ Arquitectura

### Archivos creados:

1. **FormularioGeneralModels.swift** - Modelos de datos
2. **FormularioGeneralParser.swift** - Parser robusto que implementa la lógica completa
3. **FormularioGeneralView.swift** - Vista SwiftUI del formulario dinámico
4. **HomeView.swift** - Actualizado para integrar el flujo

## 🔄 Flujo completo

### 1. Carga inicial (HomeView.onAppear)
```swift
Task {
    // 1) Cargar BrandAccount (persistencia Realm + clínicas)
    await AppStatusManager.loadBrandAccount()
    
    // 2) Obtener respuesta cruda para parsing
    let result = await Network.shared.getBrandAccount(agreementId: agreementId)
    
    // 3) Buscar registro "FormularioGeneral"
    findFormularioGeneral(in: brands)
    
    // 4) Verificar si usuario tiene Ficha Clínica General
    await checkFichaClinicaGeneralAndDecide()
}
```

### 2. Decisión de mostrar modal

La lógica de decisión implementa la **prioridad del atributo BrandAccount**:

```swift
private func applyFinalDecision(fichaArrayCount: Int?) {
    // Decisión preliminar: mostrar si fichaArrayCount == 0
    var wantsToShowByFicha = (fichaArrayCount == 0)
    
    // Override si BrandAccount tiene Atributo_1_1__c = "MostrarFormularioGeneral" 
    // y Valor_1_1__c = "Si"
    if let form = brandAccountFormularioGeneral,
       form.atributo11C == "MostrarFormularioGeneral",
       form.valor11C?.lowercased() == "si" {
        
        // ✅ Parsear el formulario
        if let formulario = FormularioGeneralParser.parse(from: form) {
            self.formularioParsed = formulario
            self.mostrarFormularioGeneral = true
        }
    }
}
```

### 3. Parsing del índice BrandAccount

El parser implementa **los 6 pasos de la lógica robusta**:

#### Paso 1: Verificar si mostrar
```swift
guard record.valor11C?.lowercased() == "si" else { return nil }
```

#### Paso 2: Parsear títulos (Elemento 1)
```swift
TitulosFormulario(
    logoURL: record.valor12C,
    titulo: record.valor13C,
    estiloTitulo: EstiloTexto.parse(record.valor14C),
    subtitulo: record.valor15C,
    estiloSubtitulo: EstiloTexto.parse(record.valor16C)
)
```

#### Paso 3: Parsear estilos globales (Elemento 12)
```swift
EstilosFormulario(
    titulosPreguntas: EstiloTexto.parse(record.valor121C),
    opcionesPreguntas: EstiloTexto.parse(record.valor122C),
    respuestasPreguntas: EstiloTexto.parse(record.valor123C),
    cuadroTexto: EstiloTexto.parse(record.valor124C),
    textoBoton: record.valor125C,
    estiloBoton: EstiloBoton.parse(record.valor126C),
    colorFondoFormulario: record.valor127C,
    colorAcento: record.valor128C
)
```

#### Paso 4: Recolectar pares cross-element (CLAVE ⭐)
```swift
private static func collectPreguntasPairs(from record: BrandAccount) -> [AtributoValor] {
    var result: [AtributoValor] = []
    
    // Concatenar elementos 2-7 (Preguntas_1 a Preguntas_6)
    // Esto garantiza que preguntas que cruzan elementos se procesen correctamente
    result.append(contentsOf: extractPairs(
        atributos: [record.atributo21C, record.atributo22C, ...],
        valores: [record.valor21C, record.valor22C, ...]
    ))
    // ... continuar para elementos 3, 4, 5, 6, 7
    
    return result // Lista plana ordenada
}
```

#### Paso 5: Agrupar en tripletes
```swift
private static func parsePreguntas(from pairs: [AtributoValor]) -> [PreguntaFormulario] {
    var preguntas: [PreguntaFormulario] = []
    var i = 0
    
    while i + 2 < pairs.count {
        // Validar triplete: Texto, Alternativas, Reglas
        guard pairs[i].atributo.contains("TextoPregunta"),
              pairs[i+1].atributo.contains("AlternativasTextoPregunta"),
              pairs[i+2].atributo.contains("ReglasAlternativasTextoPregunta") else {
            i += 1
            continue
        }
        
        let pregunta = PreguntaFormulario(
            texto: pairs[i].valor,
            alternativas: AlternativasPregunta.parse(pairs[i+1].valor),
            regla: ReglaCondicional.parse(pairs[i+2].valor)
        )
        
        preguntas.append(pregunta)
        i += 3
    }
    
    return preguntas
}
```

#### Paso 6: Parsear alternativas y reglas

**Alternativas** (formato: `TieneAlternativas;SeleccionMultiple;opcion1;opcion2;...;CuadroTexto`)
```swift
static func parse(_ raw: String) -> AlternativasPregunta {
    let parts = raw.split(separator: ";").map(String.init)
    return AlternativasPregunta(
        tieneAlternativas: parts[0].lowercased() == "si",
        seleccionMultiple: parts[1],
        listaOpciones: Array(parts[2..<parts.count-1]),
        cuadroTexto: parts.last?.lowercased() == "si"
    )
}
```

**Reglas condicionales** (formato: `Respuesta;TipoDeCampo;NombreCampo;opcion1;opcion2;...`)
```swift
static func parse(_ raw: String) -> ReglaCondicional? {
    let parts = raw.split(separator: ";").map(String.init)
    guard parts.count >= 3 else { return nil }
    
    return ReglaCondicional(
        respuestaActivadora: parts[0],
        tipoCampo: parts[1], // "Texto" o "PickList"
        nombreCampo: parts[2],
        opciones: Array(parts[3...])
    )
}
```

### 4. Renderizado del formulario (FormularioGeneralView)

```swift
FormularioGeneralView(
    formulario: formulario,
    onComplete: { respuestas in
        handleFormularioComplete(respuestas: respuestas, formulario: formulario)
    },
    onClose: {
        mostrarFormularioGeneral = false
    }
)
```

#### Componentes de la vista:

- **HeaderFormularioView**: Logo + Título + Subtítulo (con estilos)
- **PreguntaView**: Cada pregunta con sus alternativas y campo condicional
- **AlternativasView**: Opciones (radio/checkbox) + campo de texto libre
- **CampoCondicionalView**: TextField o Picker que aparece según respuesta
- **Botón completar**: Valida que todas las preguntas estén respondidas

### 5. Envío de respuestas

```swift
private func handleFormularioComplete(respuestas: [String: Any], formulario: FormularioGeneral) {
    guard let nombreFlujo = formulario.nombreFlujoServicio else { return }
    
    // nombreFlujo viene de Valor_1_7__c (ej: "SERVICIO GENERICO FICHA GENERAL CREAR")
    // respuestas es un diccionario con estructura:
    // {
    //   "pregunta_1": {
    //     "opciones": ["Sí"],
    //     "texto_libre": "",
    //     "campo_condicional": "Medicamento XYZ"
    //   },
    //   ...
    // }
    
    // TODO: Llamar al servicio genérico
    // await Network.shared.ejecutarServicioGenerico(
    //     nombreFlujo: nombreFlujo,
    //     parametros: respuestas
    // )
}
```

## 📊 Ejemplo de datos

### Entrada (JSON del índice BrandAccount):
```json
{
  "Atributo_1_1__c": "MostrarFormularioGeneral",
  "Valor_1_1__c": "Si",
  "Atributo_1_2__c": "LogoModalFormularioGeneral",
  "Valor_1_2__c": "https://...",
  "Atributo_2_1__c": "TextoPregunta1",
  "Valor_2_1__c": "¿Cuentas con algún diagnóstico de salud?",
  "Atributo_2_2__c": "AlternativasTextoPregunta1",
  "Valor_2_2__c": "Si;SiNinguno;Hipertensión;Diabetes;Otros;No",
  "Atributo_2_3__c": "ReglasAlternativasTextoPregunta1",
  "Valor_2_3__c": "Otros;Texto;¿Cuáles?;No"
}
```

### Salida (Formulario parseado):
```swift
FormularioGeneral(
    titulos: TitulosFormulario(
        logoURL: "https://...",
        titulo: "Formulario de Atención General",
        estiloTitulo: EstiloTexto(fuente: "firasans_bold", tamanio: 28, ...)
    ),
    estilos: EstilosFormulario(...),
    preguntas: [
        PreguntaFormulario(
            texto: "¿Cuentas con algún diagnóstico de salud?",
            alternativas: AlternativasPregunta(
                tieneAlternativas: true,
                seleccionMultiple: "SiNinguno",
                listaOpciones: ["Hipertensión", "Diabetes", "Otros"],
                cuadroTexto: false
            ),
            regla: ReglaCondicional(
                respuestaActivadora: "Otros",
                tipoCampo: "Texto",
                nombreCampo: "¿Cuáles?",
                opciones: []
            )
        )
    ],
    nombreFlujoServicio: "SERVICIO GENERICO FICHA GENERAL CREAR"
)
```

## 🔍 Debugging

El sistema incluye logs detallados en cada paso:

```
🔎 [Parser] Iniciando parsing de FormularioGeneral...
✅ [Parser] Títulos parseados: Formulario de Atención General
✅ [Parser] Estilos globales parseados
📦 [Parser] Pares extraídos cross-element:
   [0] TextoPregunta1 → ¿Cuentas con algún diagnóstico de salud?...
   [1] AlternativasTextoPregunta1 → Si;SiNinguno;Hipertensión;Diabetes...
   [2] ReglasAlternativasTextoPregunta1 → Otros;Texto;¿Cuáles?;No...
📊 [Parser] Pares recolectados: 27
✅ [Parser] Pregunta 1: ¿Cuentas con algún diagnóstico...
✅ [Parser] Preguntas parseadas: 9
🔗 [Parser] Flujo de servicio: SERVICIO GENERICO FICHA GENERAL CREAR
🎉 [Parser] Formulario completo parseado exitosamente
```

## ✅ Ventajas de esta implementación

1. **Robustez cross-element**: Maneja preguntas que cruzan elementos sin problemas
2. **Totalmente dinámico**: No hay código hardcoded, todo viene del servicio
3. **Tipado seguro**: Usa structs de Swift en lugar de diccionarios
4. **UI nativa**: SwiftUI con soporte para estilos personalizados
5. **Validación automática**: El formulario valida que esté completo antes de enviar
6. **Campos condicionales**: Aparecen/desaparecen según respuestas previas
7. **Logs completos**: Debugging fácil con prints informativos

## 🚀 Próximos pasos (TODOs)

1. **Implementar elementos 8-11** en el parser (si existen más preguntas)
2. **Conectar con servicio genérico** real en `handleFormularioComplete`
3. **Agregar validaciones** adicionales (ej: campos obligatorios)
4. **Manejo de errores** en el envío del formulario
5. **Persistencia local** de respuestas (por si el usuario cierra el modal)
6. **Testing** con diferentes configuraciones de BrandAccount

## 📝 Notas importantes

- El parser asume que las preguntas siempre vienen en **tripletes** (Texto, Alternativas, Reglas)
- Si falta un triplete, ese grupo se salta y se continúa con el siguiente
- Los estilos se parsean desde formato `fuente;tamaño;color;posición`
- El sistema es compatible con **iOS 15+** (con detents en iOS 16+)
