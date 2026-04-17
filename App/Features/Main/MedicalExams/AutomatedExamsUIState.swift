//
//  AutomatedExamsUIState.swift
//  CareAssistance
//
//  Created by Care Assistance on 30/03/2026.
//

import Foundation

// MARK: - Estado principal
struct AutomatedExamsUIState {
    // Custom Record - Elemento 1: Banners pantalla principal (ExamsView hub)
    var bannersHub: [BannerExamItem] = []

    // Custom Record - Elemento 2: Header pantalla principal
    var header = ExamHeaderConfig()

    // Custom Record - Elemento 3: Secciones iniciales (3 opciones)
    var secciones: [SeccionInicialExam] = []

    // Custom Record - Elemento 4: Config lista de categorías (vista generar exámenes)
    var categoriasListaConfig = CategoriaListaConfig()

    // Custom Record - Elemento 5: Config carrito de exámenes
    var carrito = CarritoExamConfig()

    // Custom Record - Elemento 6: Config modal selección exámenes
    var seleccionExamenes = SeleccionExamenesConfig()

    // Custom Record - Elemento 7: Popup ver detalle/resumen carrito
    var popupDetalleCarrito = PopupDetalleCarritoConfig()

    // Custom Record - Elemento 8: Color back arrow de toda la sección exámenes
    var backArrowColorSeccion: String = "#00BBDC"

    // Custom Record - Elemento 9: "Seleccionar Todos" + Badges en Prescripciones Médicas
    var seleccionarTodosTexto: String = "Seleccionar Todos"
    var seleccionarTodosAttr = TextExamAttributes()
    var badgeExamenAutomatizado = BadgeConfig(texto: "Examen automatizado", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#7B61FF")
    var badgeOrdenMedica = BadgeConfig(texto: "Orden médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00BBDC")
    var badgeRecetaMedica = BadgeConfig(texto: "Receta médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00B894")

    // Main Record - Elementos 1-2: Categorias (hasta 32)
    var categorias: [CategoriaExamen] = []

    // Main Record - Elemento 3: Campos validacion
    var validacion = ValidacionExamenesConfig()

    // Main Record - Popups
    var popupCategorias = PopupExamConfig()
    var popupConfirmDatos = PopupExamConfig()
    var popupConsentimiento = PopupConsentimientoConfig()
    var popupEnviarEmail = PopupExamConfig()
    var popupExamenSinCosto = PopupExamConfig()
    var popupCarga = PopupCargaConfig()
    var popupExamenRealizado = PopupExamConfig()
    var popupSugerencia = PopupExamConfig()
}

// MARK: - Banner
struct BannerExamItem: Identifiable, Hashable {
    let id = UUID()
    var imageURL: String = ""
    var linkURL: String = ""
}

// MARK: - Header pantalla principal (Elemento 2)
struct ExamHeaderConfig {
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var blockPosition: String = "Center"
    var botonVolver = ButtonExamConfig()
}

// MARK: - Seccion inicial (opcion circular)
struct SeccionInicialExam: Identifiable, Hashable {
    let id = UUID()
    var numero: Int = 0
    var nombre: String = ""
    var iconURL: String = ""
    var visible: Bool = true
    var tituloAttr = TextExamAttributes()
}

// MARK: - Config lista de categorías (Elemento 4 nuevo - CustomListaCategoriasExamenes)
struct CategoriaListaConfig {
    var titulo: String = "Exámenes Automatizados"
    var tituloAttr = TextExamAttributes()
    var subtitulo: String = ""
    var subtituloAttr = TextExamAttributes()
    var blockPosition: String = "Center"
    var backArrowColor: String = "#00BBDC"
}

// MARK: - Categoria de examen
struct CategoriaExamen: Identifiable, Hashable {
    let id = UUID()
    var nombre: String = ""
    var tituloTip: String = ""
    var descripcionTip: String = ""
    var iconURL: String = ""
    var claveApi: String = "" // "Categoria_Z__c"
}

// MARK: - Validacion
struct ValidacionExamenesConfig {
    var paisExamen: String = ""
    var tipoExamen: String = ""
    var colorSpinner: String = "#00BBDC"
    var sexoPaciente: String = ""   // "Masculino", "Femenino", o vacio (sin filtro)
    var edadPaciente: Int = 0       // 0 = sin filtro por edad
}

// MARK: - Popup generico
struct PopupExamConfig {
    var iconURL: String = ""
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var labelTexto: String = ""
    var labelAttr = TextExamAttributes()
    var respuestaAttr = TextExamAttributes()
    var btnAceptar = ButtonExamConfig()
    var btnCerrar = ButtonExamConfig()
    // Campos adicionales para ConfirmDatos y EnviarEmail
    var colorBordeConTexto: String = "#5B6770"
    var colorBordeSinTexto: String = "#FF0000"
    var colorBarraScroll: String = "#EDEDED"
    var colorCirculoCalendario: String = "#00BBDC"
}

// MARK: - Popup Carga (dialog de loading con timer configurable)
struct PopupCargaConfig {
    var iconURL: String = ""
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var colorSpinner: String = "#00BBDC"
    var segundosMostrar: Int = 6
}

// MARK: - Popup Consentimiento (extiende popup con checkbox)
struct PopupConsentimientoConfig {
    var iconURL: String = ""
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var checkboxTexto: String = ""
    var checkboxTextoAttr = TextExamAttributes()
    var checkboxColor: String = "#00BBDC"
    var btnAceptar = ButtonExamConfig()
    var btnCancelar = ButtonExamConfig()
    var colorBarraScroll: String = "#EDEDED"
}

// MARK: - Seleccion de examenes (Elemento 6 nuevo - ModalSeleccionExamenes)
struct SeleccionExamenesConfig {
    // Elem 6.1: Atributos título categoría
    var tituloCategoriaAttr = TextExamAttributes()
    // Elem 6.2-6.3: Seleccionar todos
    var seleccionarTodosTexto: String = "Selecciona todos los exámenes"
    var seleccionarTodosAttr = TextExamAttributes()
    // Elem 6.4: Atributos lista exámenes (colorFondo = colorHoverSeleccion)
    var textoListaAttr = TextExamAttributes()
    // Elem 6.5: Color checkbox
    var checkboxColorSeleccionado: String = "#00BBDC"
    // Elem 6.6-6.7: Contador exámenes seleccionados
    var contadorTexto: String = "/ de / exámenes seleccionados"
    var contadorAttr = TextExamAttributes()
    // Elem 6.8-6.9: Sin exámenes para seleccionar
    var sinExamenesTexto: String = ""
    var sinExamenesAttr = TextExamAttributes()
    // Elem 6.10: Botón aceptar/agregar
    var btnAgregar = ButtonExamConfig()
    // Elem 6.11: Botón cancelar
    var btnCancelar = ButtonExamConfig()
    // Elem 6.12: Color barra scroll
    var colorBarraScroll: String = "#EDEDED"
    // Elem 6.13: Color spinner
    var colorSpinner: String = "#00BBDC"
    // Derivado de textoListaAttr.colorFondo (colorHoverSeleccion)
    var colorFondoSeleccionado: String = "#E8F5E9"
    // Subtitulo (no viene en nueva estructura, pero vista lo usa con fallback)
    var subtituloTexto: String = ""
    var subtituloAttr = TextExamAttributes()
}

// MARK: - Carrito de exámenes (Elemento 5 nuevo - CustomCarritoExamenes)
struct CarritoExamConfig {
    // Elem 5.1-5.2: Título
    var titulo: String = "Carrito de Exámenes"
    var tituloAttr = TextExamAttributes()
    // Elem 5.3: Color icono carrito
    var carritoColor: String = "#00BBDC"
    // Elem 5.4-5.5: Texto sin exámenes agregados
    var sinExamenesTexto: String = "No hay exámenes agregados aún..."
    var sinExamenesAttr = TextExamAttributes()
    // Elem 5.6-5.7: Total exámenes agregados
    var totalExamenesTexto: String = "Total de exámenes agregados:"
    var totalExamenesAttr = TextExamAttributes()
    // Elem 5.8: Atributos categoría agregada (con colorFondo)
    var categoriaAttr = TextExamAttributes()
    // Elem 5.9: Atributos nombres exámenes
    var nombresExamenesAttr = TextExamAttributes()
    // Elem 5.10: Atributos cantidad examen
    var cantidadAttr = TextExamAttributes()
    // Elem 5.11: Color basurero
    var basureroColor: String = "#FF0000"
    // Elem 5.12: Botón ver resumen
    var btnVerResumen = ButtonExamConfig()
    // Elem 5.13: Botón limpiar todo
    var btnLimpiar = ButtonExamConfig()
    // Main Record Elem 12.7: Texto "Antes de continuar"
    var antesDeContinuarTexto: String = ""
    var antesDeContinuarAttr = TextExamAttributes()
    // Main Record Elem 12.8: SubTexto "Antes de continuar"
    var subAntesDeContinuarTexto: String = ""
    var subAntesDeContinuarAttr = TextExamAttributes()
}

// MARK: - Popup detalle/resumen carrito (Elemento 7 nuevo - PopUpVerDetalleCarrito)
struct PopupDetalleCarritoConfig {
    // Elem 7.1: Icono
    var iconURL: String = ""
    // Elem 7.2-7.3: Título
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    // Elem 7.4-7.5: Subtítulo
    var subtitulo: String = ""
    var subtituloAttr = TextExamAttributes()
    // Elem 7.6: Atributos categoría (con colorFondo)
    var categoriaAttr = TextExamAttributes()
    // Elem 7.7: Atributos nombres exámenes
    var nombresExamenesAttr = TextExamAttributes()
    // Elem 7.8: Atributos cantidad
    var cantidadAttr = TextExamAttributes()
    // Elem 7.9: Color basurero
    var basureroColor: String = "#FF0000"
    // Elem 7.10: Botón aceptar/continuar
    var btnAceptar = ButtonExamConfig()
    // Elem 7.11: Botón cerrar
    var btnCerrar = ButtonExamConfig()
    // Elem 7.12: Color barra scroll
    var colorBarraScroll: String = "#EDEDED"
}

// MARK: - Badge config para tipos de documento
struct BadgeConfig {
    var texto: String = ""
    var font: String = "FiraSans-Medium"
    var size: String = "11"
    var colorTexto: String = "#FFFFFF"
    var colorFondo: String = "#00BBDC"
}

// MARK: - Atributos de texto reutilizable
struct TextExamAttributes: Hashable {
    var font: String = "FiraSans-Regular"
    var size: String = "14"
    var color: String = "#333F48"
    var alignment: String = "Left"
    var colorFondo: String = "" // Color de fondo (para headers de categoría, etc.)
}

// MARK: - Boton reutilizable
struct ButtonExamConfig: Hashable {
    var texto: String = ""
    var colorTexto: String = ""
    var colorFondo: String = ""
    var font: String = ""
    var size: String = ""
    // Para botones con estado activo/inactivo
    var colorTextoActivo: String = ""
    var colorFondoActivo: String = ""
    var colorTextoInactivo: String = ""
    var colorFondoInactivo: String = ""
    // Para botones con hover
    var colorHover: String = ""
}
