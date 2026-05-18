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

    // (legacy) Color back arrow del hub de exámenes y de AutomatedExamsView.
    // Antes se parseaba del Elemento 8, pero ese elemento ahora es
    // VistaDetalleMisArchivosDeSalud. Este campo queda con default fijo —
    // si se quisiera dinámico, conviene crear un atributo dedicado en otro elemento.
    var backArrowColorSeccion: String = "#00BBDC"

    // Custom Record - Elemento 8: VistaDetalleMisArchivosDeSalud
    // Config completa de la pantalla "Detalle de Mi Archivo de Salud"
    // (al hacer click sobre una card de la lista de Mis Archivos de Salud).
    var vistaDetalleMisArchivos = VistaDetalleMisArchivosConfig()

    // Custom Record - Elemento 10: Sección Mis Archivos de Salud
    var botonSubirExamen = ButtonExamConfig()
    var badgeDetallePrescripciones = BadgeDetalleConfig(texto: "Creado por el paciente", colorTexto: "#D4A017", colorFondo: "#FFF7E6", font: "FiraSans-Regular", size: "15", icono: "stethoscope")
    var badgeDetalleRecetaMedica = BadgeDetalleConfig(texto: "Receta médica", colorTexto: "#1890FF", colorFondo: "#E6F4FF", font: "FiraSans-Regular", size: "15", icono: "pills.fill")
    var badgeDetalleExamenMedico = BadgeDetalleConfig(texto: "Dr/a {ProfesionalResponsable}", colorTexto: "#52C41A", colorFondo: "#F0F9EB", font: "FiraSans-Regular", size: "15", icono: "stethoscope")
    var badgeCargadoPorPaciente = BadgeDetalleConfig(texto: "Cargado por el Paciente", colorTexto: "#FFFFFF", colorFondo: "#7B61FF", font: "FiraSans-Medium", size: "11", icono: "person.fill")

    // Custom Record - Elemento 11: Dialog Eliminar Examen Subido
    var dialogEliminarExamen = DialogEliminarExamenConfig()

    // Custom2 Record - Elemento 1: Dialog Exámenes Enviados Correctamente
    var dialogExamenesEnviados = DialogExamenesEnviadosConfig()

    // Custom2 Record - Elemento 2: Dialog Confirmar Eliminar Documento Subido a Orden Examen
    var dialogEliminarDocOrden = DialogEliminarExamenConfig()

    // Custom2 Record - Elemento 3: Dialog Confirmar Eliminar Mi Archivo de Salud
    var dialogEliminarMiArchivo = DialogEliminarExamenConfig()

    // Custom Record - Elemento 12: VistaPrincipalMisArchivosDeSalud (config completa)
    var vistaMisArchivos = VistaMisArchivosConfig()

    // Custom Record - Elemento 13: Botones vista detalle examen subido en Mis Archivos de Salud
    var botonesDetalleExamen = BotonesDetalleExamenConfig()

    // Custom Record - Elemento 9: "Seleccionar Todos" + Badges en Prescripciones Médicas
    var seleccionarTodosTexto: String = "Seleccionar Todos"
    var seleccionarTodosAttr = TextExamAttributes()
    var badgeExamenAutomatizado = BadgeConfig(texto: "Examen automatizado", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#7B61FF")
    var badgeOrdenMedica = BadgeConfig(texto: "Orden médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00BBDC")
    var badgeRecetaMedica = BadgeConfig(texto: "Receta médica", font: "FiraSans-Medium", size: "11", colorTexto: "#FFFFFF", colorFondo: "#00B894")

    // Main Record - Elemento 13: VistaPrincipalPrescripcionesMedicas
    // Config completa de la pantalla Prescripciones Médicas (lista con badges).
    // A partir de ahora esta pantalla NO depende de SecMas — toda su UI
    // dinámica se lee desde Elemento 13 del record ExamenesAutomatizados.
    var vistaPrincipalPrescripciones = VistaPrincipalPrescripcionesConfig()

    // Custom Record - Elemento 9: VistaDetallePrescripcionesMedicas
    // Config completa de la pantalla "Detalle de prescripción médica"
    // (al hacer click sobre una card). Reemplaza por completo al uso anterior
    // del Elemento 9 (SeleccionarTodos, movido a Elemento 13.5).
    var vistaDetallePrescripciones = VistaDetallePrescripcionesConfig()

    // Custom Record - Elemento 10: VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud
    // Config completa de la pantalla "Subir Examen" (compartida entre el flujo
    // de detalle de prescripción médica y Mis Archivos de Salud). Reemplaza
    // por completo al uso anterior del Elemento 10 (SeccionMisArchivosDeSalud).
    var vistaSubirExamen = VistaSubirExamenConfig()

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

// MARK: - Dialog Exámenes Enviados Correctamente (Custom2 - Elemento 1)
struct DialogExamenesEnviadosConfig {
    var icono: String = "checkmark"          // SF Symbol del ícono superior
    var colorIcono: String = "#4CAF50"       // Color del ícono
    var colorFondoIcono: String = "#E8F5E9"  // Color del círculo de fondo
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var botonAceptar = ButtonExamConfig()
}

// MARK: - Dialog Eliminar Examen Subido (Elemento 11)
struct DialogEliminarExamenConfig {
    var icono: String = ""               // SF Symbol del ícono superior (vacío = usa "!" hardcodeado)
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    var botonAceptar = ButtonExamConfig()
    var botonCancelar = ButtonExamConfig()
}

// MARK: - Banner
struct BannerExamItem: Identifiable, Hashable {
    let id = UUID()
    var imageURL: String = ""
    var linkURL: String = ""
}

// MARK: - Header pantalla principal (Elemento 2)
// Config completa de la pantalla hub (Archivo de Salud) donde aparecen las
// 3 opciones: Exámenes Automatizados, Prescripciones Médicas y Mis Archivos.
struct ExamHeaderConfig {
    // 2.1 + 2.2 TituloHome + AtributosTituloHome
    var titulo: String = ""
    var tituloAttr = TextExamAttributes()
    // 2.3 + 2.4 DescripcionHome + AtributosDescripcionHome
    var descripcion: String = ""
    var descripcionAttr = TextExamAttributes()
    // 2.5 Block
    var blockPosition: String = "Center"
    // 2.6 BotonVolverHome
    var botonVolver = ButtonExamConfig()
    // 2.7 ColorCirculoBannerSeleccionado
    var colorCirculoBannerSeleccionado: String = "#00BBDC"
    // 2.8 BackArrow(Color)
    var backArrowColor: String = ""
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

// MARK: - Badge Detalle Prescripciones Médicas (Elemento 10)
struct BadgeDetalleConfig {
    var texto: String = ""
    var colorTexto: String = ""
    var colorFondo: String = ""
    var font: String = "FiraSans-Regular"
    var size: String = "15"
    var icono: String = "stethoscope"
}

// MARK: - Botones Vista Detalle Examen Subido (Elemento 13)
struct BotonesDetalleExamenConfig {
    var botonEliminar = ButtonExamConfig(texto: "Eliminar", colorTexto: "#FFFFFF", colorFondo: "#FF3B30", font: "FiraSans-Bold", size: "16")
    var botonDescargar = ButtonExamConfig(texto: "Descargar", colorTexto: "#FFFFFF", colorFondo: "#00BBDC", font: "FiraSans-Bold", size: "16")
    var botonCompartir = ButtonExamConfig(texto: "Compartir", colorTexto: "#FFFFFF", colorFondo: "#00BBDC", font: "FiraSans-Bold", size: "16")
    var tituloArchivosAdjuntos: String = "Archivos adjuntos"
    var tituloArchivosAdjuntosAttr = TextExamAttributes()
}

// MARK: - VistaPrincipalMisArchivosDeSalud (Custom Record - Elemento 12)
// Config completa de la pantalla "Mis Archivos de Salud". Parseada desde
// el Elemento 12 del record `ExamenesAutomatizadosCustom`
// (VistaPrincipalMisArchivosDeSalud). Es la ÚNICA fuente dinámica que
// alimenta esta pantalla — ya no se mezcla con SecMas / secciones / Elemento 8.
struct VistaMisArchivosConfig {
    // 12.1–12.6 Badges por tipo de archivo (Tipo_de_Archivo__c de Salesforce)
    var badgeExamenImagen = BadgeConfig(texto: "Examen de Imagen", font: "FiraSans-Medium", size: "11", colorTexto: "#722ed1", colorFondo: "#f9f0ff")
    var badgeRecetaMedica = BadgeConfig(texto: "Receta Médica", font: "FiraSans-Medium", size: "11", colorTexto: "#0183c7", colorFondo: "#e6f4ff")
    var badgeExamenLaboratorio = BadgeConfig(texto: "Examen de Laboratorio", font: "FiraSans-Medium", size: "11", colorTexto: "#52c41a", colorFondo: "#f0f9eb")
    var badgeOrdenExamen = BadgeConfig(texto: "Orden de Exámenes", font: "FiraSans-Medium", size: "11", colorTexto: "#d46b08", colorFondo: "#fff7e6")
    var badgeInformeMedico = BadgeConfig(texto: "Informe Médico", font: "FiraSans-Medium", size: "11", colorTexto: "#13c2c2", colorFondo: "#e6fffb")
    var badgeOtros = BadgeConfig(texto: "Otros", font: "FiraSans-Medium", size: "11", colorTexto: "#8c8c8c", colorFondo: "#f5f5f5")

    // 12.7 IconoBasuraEliminarMiArchivoSalud(Size;Color)
    var iconoBasuraSize: String = "16"
    var iconoBasuraColor: String = "#FF4D4F"

    // 12.8 BackArrow(Color)
    var backArrowColor: String = ""

    // 12.9 TituloGeneralMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)
    var tituloTexto: String = ""
    var tituloAttr = TextExamAttributes()

    // 12.10 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
    var tituloCardAttr = TextExamAttributes()

    // 12.11 TextoPlaceholderFiltro(Fuente;Texto;Size;Color)
    var placeholderTexto: String = ""
    var placeholderAttr = TextExamAttributes()

    // 12.12 IconoFiltro(Icono;Size;Color)
    var iconoFiltro: String = ""
    var iconoFiltroSize: String = ""
    var iconoFiltroColor: String = ""

    // 12.13 FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)
    var fechaAttr = TextExamAttributes()
    var fechaFormato: String = "dd/MM/yyyy"
    var fechaIcono: String = ""
    var fechaIconoColor: String = ""

    // 12.14 TextoEmptyState(Fuente;Texto;Size;Color)
    var emptyStateTexto: String = ""
    var emptyStateAttr = TextExamAttributes()

    // 12.15 BarraVerticalCardMisArchivosDeSalud(Color)
    var barraVerticalColor: String = ""

    // 12.16 BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
    var botonSubirExamen = ButtonExamConfig()
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
    // Para botones con icono
    var icono: String = ""
    var colorIcono: String = ""
    // Tamaño dedicado del icono (independiente del size del texto).
    // Si está vacío, se usa `size` del botón como fallback.
    var iconoSize: String = ""
    // Para botones con estado activo/inactivo
    var colorTextoActivo: String = ""
    var colorFondoActivo: String = ""
    var colorTextoInactivo: String = ""
    var colorFondoInactivo: String = ""
    // Para botones con hover
    var colorHover: String = ""
    // Para botones con borde
    var colorBorde: String = ""
}

// MARK: - VistaPrincipalPrescripcionesMedicas (Main Record - Elemento 13)
// Config completa de la pantalla "Prescripciones Médicas" (lista con badges).
// Parseada desde Elemento 13 del record `ExamenesAutomatizados` (MAIN).
struct VistaPrincipalPrescripcionesConfig {
    // 13.1 BackArrow(Color)
    var backArrowColor: String = ""

    // 13.2 TituloPrescripcionesMedicas(Fuente;Texto;Size;Color)
    var tituloTexto: String = ""
    var tituloAttr = TextExamAttributes()

    // 13.3 TextoPlaceholderFiltro(Fuente;Texto;Size;Color)
    var placeholderTexto: String = ""
    var placeholderAttr = TextExamAttributes()

    // 13.4 IconoFiltro(Icono;Size;Color)
    var iconoFiltro = IconConfig()

    // 13.5 TextoSeleccionarTodos(Fuente;Texto;Size;Color;ColorCheckboxActivo)
    var seleccionarTodosTexto: String = ""
    var seleccionarTodosAttr = TextExamAttributes()
    var seleccionarTodosCheckboxColor: String = ""

    // 13.6 TextoContadorExamenesSeleccionados(Fuente;Size;Color)
    var contadorAttr = TextExamAttributes()

    // 13.7 BotonDescargar(Texto;ColorTexto;ColorBoton;Icono)
    var botonDescargar = ButtonExamConfig()

    // 13.8 BotonCompartir(Texto;ColorTexto;ColorBoton;Icono)
    var botonCompartir = ButtonExamConfig()

    // 13.9 AtributosCard(ColorBarraVertical;ColorCheckboxActivo;ColorBordeActivo;ColorEstrella)
    var cardColorBarraVertical: String = ""
    var cardColorCheckboxActivo: String = ""
    var cardColorBordeActivo: String = ""
    var cardColorEstrella: String = ""

    // 13.10 TituloNombreCardExamen(Fuente;Size;Color)
    var tituloCardAttr = TextExamAttributes()

    // 13.14 FechaExamenCard(Fuente;Size;Color;Formato;Icono;ColorIcono)
    // El "Formato" viene en notación Salesforce (DD/MM/AAAA o DD/MM/YYYY)
    // y se mapea a formato iOS DateFormatter al parsear.
    var fechaCardAttr = TextExamAttributes()
    var fechaCardFormato: String = "dd/MM/yyyy"
    var fechaCardIcono: String = ""
    var fechaCardIconoColor: String = ""

    // 13.15 TextoEmptyState(Fuente;Texto;Size;Color)
    var emptyStateTexto: String = ""
    var emptyStateAttr = TextExamAttributes()

    // 13.16 AtributosDescripcionExamenCard(Fuente;Size;Color)
    // Estilo del texto de descripción de cada card (ej: "Examen creado
    // automáticamente desde la plataforma"). El TEXTO en sí viene del
    // registro individual del examen (no de esta config) — esto controla
    // solo la tipografía y color.
    var descripcionCardAttr = TextExamAttributes()
}

// MARK: - Icono reutilizable (nombre + size + color)
struct IconConfig: Hashable {
    var nombre: String = ""
    var size: String = ""
    var color: String = ""
}

// MARK: - VistaDetallePrescripcionesMedicas (Custom Record - Elemento 9)
// Config completa de la pantalla "Detalle de prescripción médica".
// Parseada desde Elemento 9 del record `ExamenesAutomatizadosCustom`.
struct VistaDetallePrescripcionesConfig {
    // 9.1 BackArrow(Color)
    var backArrowColor: String = ""

    // 9.2 TituloGeneralDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)
    var tituloTexto: String = ""
    var tituloAttr = TextExamAttributes()

    // 9.3 IconoEstrella(Size;Color)
    var iconoEstrellaSize: String = ""
    var iconoEstrellaColor: String = ""

    // 9.4 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
    var tituloCardAttr = TextExamAttributes()

    // 9.5 BadgeDetalleTipoPrescripcionesMedicas
    //     (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
    var badgeCreadoPaciente = BadgeDetalleConfig()

    // 9.6 FechaDetallePrescripcion(Fuente;Size;Color;Formato;Icono;ColorIcono)
    var fechaAttr = TextExamAttributes()
    var fechaFormato: String = "dd/MM/yyyy"
    var fechaIcono: String = ""
    var fechaIconoColor: String = ""

    // 9.7 DetalleIndicaciones(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
    var indicacionesTitulo: String = ""
    var indicacionesTituloAttr = TextExamAttributes()

    // 9.8 AtributosDetalleIndicaciones(Fuente;Size;Color)
    var indicacionesTextoAttr = TextExamAttributes()

    // 9.9 DetalleExamenAdjunto(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
    var examenAdjuntoTitulo: String = ""
    var examenAdjuntoTituloAttr = TextExamAttributes()

    // 9.10 ColorIconoExamenAdjunto(Color;Size)
    var examenAdjuntoIconoColor: String = ""
    var examenAdjuntoIconoSize: String = ""

    // 9.11 BotonDescargarDetalle
    //      (TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
    var botonDescargar = ButtonExamConfig()

    // 9.12 BotonCompartirDetalle (mismo formato que 9.11)
    var botonCompartir = ButtonExamConfig()

    // 9.13 BotonSubirExamen(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
    // Se muestra cuando la prescripción NO tiene un documento adjunto.
    var botonSubirExamen = ButtonExamConfig()

    // 9.14 BadgeDetalleTipoRecetaMedica
    //      (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
    var badgeRecetaMedica = BadgeDetalleConfig()

    // 9.15 BadgeDetalleTipoExamenMedico
    //      (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
    var badgeExamenMedico = BadgeDetalleConfig()

    // 9.16 BotonVerDocumentoEnviado(Texto;Size;ColorTexto;ColorFondo;TipoFuente)
    // Se muestra cuando la prescripción YA tiene un documento adjunto
    // (estado dual con `botonSubirExamen`).
    var botonVerDocumentoEnviado = ButtonExamConfig()
}

// MARK: - VistaSubirExamen (Custom Record - Elemento 10)
// Config completa de la pantalla "Subir Examen". Parseada desde Elemento 10
// del record `ExamenesAutomatizadosCustom` (VistaSubirExamenDetallePrescripcionesMedicasMisArchivosDeSalud).
struct VistaSubirExamenConfig {
    // 10.1 BackArrow(Color)
    var backArrowColor: String = ""

    // 10.2 TituloGeneralSubirExamenDetallePrescripcionesMedicas(Fuente;Texto;ColorTexto;Size)
    var tituloTexto: String = ""
    var tituloAttr = TextExamAttributes()

    // 10.3 TextoListaTipoDocumentoASubir(Fuente;Texto;ColorTexto;Size;Position)
    var tipoDocumentoTexto: String = ""
    var tipoDocumentoAttr = TextExamAttributes()

    // 10.4 BadgeCargadoPorElPacienteVerDocumentoEnviado
    //      (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
    var badgeCargadoPorPaciente = BadgeDetalleConfig()

    // 10.5 TextoAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)
    var adjuntarArchivoTexto: String = ""
    var adjuntarArchivoAttr = TextExamAttributes()

    // 10.6 DescripcionAdjuntarArchivo(Fuente;Texto;ColorTexto;Size;Position)
    var descripcionAdjuntarTexto: String = ""
    var descripcionAdjuntarAttr = TextExamAttributes()

    // 10.7 AtributoContainerSinArchivoAdjunto
    //      (ColorBorde;Icono;ColorIcono;SizeIcono;ColorFondoContainer)
    var containerSinArchivo = ContainerSinArchivoConfig()

    // 10.8 AtributoContainerConArchivoAdjunto
    //      (ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;
    //       IconoCancelar;ColorFondo;ColorCruz;ColorFondoContainer)
    var containerConArchivo = ContainerConArchivoConfig()

    // 10.9 TextoNota(Fuente;Texto;ColorTexto;Size;Position)
    // El "Size" puede venir ausente en Salesforce — la implementación
    // parsea de forma tolerante.
    var notaTexto: String = ""
    var notaAttr = TextExamAttributes()

    // 10.10 BotonEnviar(Texto;Size;ColorTexto;ColorFondo;TipoFuente)
    var botonEnviar = ButtonExamConfig()
}

// MARK: - Container del slot SIN archivo adjunto (10.7)
struct ContainerSinArchivoConfig {
    var colorBorde: String = ""
    var icono: String = ""           // ej: "Clip" → SF "paperclip"
    var colorIcono: String = ""
    var sizeIcono: String = ""
    var colorFondoContainer: String = ""
}

// MARK: - Container del slot CON archivo adjunto (10.8)
struct ContainerConArchivoConfig {
    var colorBorde: String = ""
    var icono: String = ""           // ej: "Imagen" → SF "photo"
    var colorIcono: String = ""
    var sizeIcono: String = ""
    var colorTextoFormato: String = ""
    var iconoCancelar: String = ""   // ej: "Cancelar" → SF "xmark.circle.fill"
    var colorFondoBotonCancelar: String = ""
    var colorCruz: String = ""
    var colorFondoContainer: String = ""
}

// MARK: - VistaDetalleMisArchivosDeSalud (Custom Record - Elemento 8)
// Config completa de la pantalla "Detalle de un archivo de salud" (al tocar
// una card de la vista Mis Archivos de Salud). Parseada desde el Elemento 8
// del record `ExamenesAutomatizadosCustom`. Es la ÚNICA fuente dinámica que
// alimenta esa pantalla — no se mezcla con otros elementos.
struct VistaDetalleMisArchivosConfig {
    // 8.1 BackArrow(Color)
    var backArrowColor: String = ""

    // 8.2 TituloGeneralDetalleMisArchivosDeSalud(Fuente;Texto;ColorTexto;Size)
    var tituloTexto: String = ""
    var tituloAttr = TextExamAttributes()

    // 8.3 AtributosTituloCardDetalle(Fuente;ColorTexto;Size)
    var tituloCardAttr = TextExamAttributes()

    // 8.4 BadgeCargadoPorElPacienteVerDocumentoEnviado
    //     (Texto;ColorTexto;ColorFondo;TipoFuente;Size;Icono)
    var badgeCargadoPorPaciente = BadgeDetalleConfig()

    // 8.5 FechaDetalleMisArchivosDeSalud(Fuente;Size;Color;Formato;Icono;ColorIcono)
    var fechaAttr = TextExamAttributes()
    var fechaFormato: String = "dd/MM/yyyy"
    var fechaIcono: String = ""
    var fechaIconoColor: String = ""

    // 8.6 DetalleArchivosAdjuntos(TextoTitulo;Fuente;Size;ColorTexto;Posicion)
    var detalleArchivosTitulo: String = ""
    var detalleArchivosAttr = TextExamAttributes()

    // 8.7 ContainerArchivoAdjunto
    //     (ColorBorde;Icono;ColorIcono;SizeIcono;ColorTextoFormato;ColorFondoContainer)
    // En el detalle de Mis Archivos NO existe estado "sin archivo" ni botón de
    // cancelar — solo se muestran archivos ya publicados.
    var containerArchivo = ContainerArchivoSimpleConfig()

    // 8.8 BotonDescargarDetalleMisArchivosDeSalud
    //     (TipoFuente;Texto;ColorTexto;Size;ColorFondo;Icono;ColorIcon;ColorBorde)
    var botonDescargar = ButtonExamConfig()

    // 8.9 BotonCompartirDetalleMisArchivosDeSalud (mismo formato que 8.8)
    var botonCompartir = ButtonExamConfig()

    // 8.10 BotonEliminarDetalleMiArchivoDeSalud(Texto;ColorTexto;ColorFondo;TipoFuente;Size)
    var botonEliminar = ButtonExamConfig()
}

// MARK: - Container simple del detalle (8.7)
// Variante reducida — sin botón cancelar (los archivos ya están publicados).
struct ContainerArchivoSimpleConfig {
    var colorBorde: String = ""
    var icono: String = ""           // ej: "Imagen" → SF "photo"
    var colorIcono: String = ""
    var sizeIcono: String = ""
    var colorTextoFormato: String = ""
    var colorFondoContainer: String = ""
}
