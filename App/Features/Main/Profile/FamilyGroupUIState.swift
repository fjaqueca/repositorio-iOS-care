//
//  FamilyGroupUIState.swift
//  CareAssistance
//

import Foundation

// MARK: - Building Blocks

/// Atributos de texto dinámicos: fuente, tamaño, color y alineación.
/// Parse de `"font;size;color;alignment"`.
struct FGTextAttributes {
    var font: String = ""
    var size: String = ""
    var color: String = ""
    var alignment: String = ""
}

/// Botón simple de 3 partes: `"texto;colorTexto;colorFondo"`.
struct FGButtonConfig {
    var texto: String = ""
    var colorTexto: String = ""
    var colorFondo: String = ""
}

/// Botón con estados activo/inactivo de 5 partes:
/// `"texto;colorTextoActivo;colorTextoInactivo;colorFondoActivo;colorFondoInactivo"`.
struct FGButton5Config {
    var texto: String = ""
    var colorTextoActivo: String = ""
    var colorTextoInactivo: String = ""
    var colorFondoActivo: String = ""
    var colorFondoInactivo: String = ""
}

/// Colores del calendario: `"ColorFlechas;ColorMes;ColorAño;ColorDiaSemana;ColorDiaMes;ColorHover;ColorTextoSeleccion;ColorFondoSeleccion"`
struct FGCalendarioConfig {
    var colorFlechas: String = ""
    var colorMes: String = ""
    var colorAnio: String = ""
    var colorDiaSemana: String = ""
    var colorDiaMes: String = ""
    var colorHover: String = ""
    var colorTextoSeleccion: String = ""
    var colorFondoSeleccion: String = ""
}

// MARK: - Elemento 1: Sección Principal

struct FGSeccionPrincipalConfig {
    // Título
    var titulo: String = ""
    var tituloAttr = FGTextAttributes()

    // Descripción
    var descripcion: String = ""
    var descripcionAttr = FGTextAttributes()

    // Icono de usuarios (URL imagen para avatar)
    var iconoUsuarios: String = ""

    // Atributos nombres de cargas (cards de miembros)
    var nombresAttr = FGTextAttributes()

    // Botón Modificar (en cada card)
    var textoBotonModificar: String = ""
    // Parse especial 5 partes: font;size;colorTexto;colorIcono;colorBorde
    var botonModificarFont: String = ""
    var botonModificarSize: String = ""
    var botonModificarColorTexto: String = ""
    var colorIconoEditar: String = ""
    var colorBordeEditar: String = ""

    // Icono eliminar — parse "activo;hover"
    var colorIconoEliminar: String = ""
    var colorIconoEliminarHover: String = ""

    // Botón Agregar Carga (button3)
    var botonAgregar = FGButtonConfig()

    // Spinner
    var colorSpinner: String = ""

    // Borde campo estático
    var colorBordeCampo: String = ""

    // Empty state (sin cargas)
    var iconoSinCargas: String = ""
    var textoSinCargas: String = ""
    var textoSinCargasAttr = FGTextAttributes()
}

// MARK: - Elemento 2: Sección Modificar

struct FGSeccionModificarConfig {
    // Título modal
    var titulo: String = ""
    var tituloAttr = FGTextAttributes()

    // Labels de campos (separados por ";"):
    // Identificacion;Nombre;Apellido;Direccion;FechaNacimiento;Sexo;Correo;Telefono
    var labels: [String] = []
    var labelsAttr = FGTextAttributes()

    // Colores
    var colorAsterisco: String = ""
    var colorBordeCampo: String = ""
    var colorBordeSeleccionado: String = ""
    var colorTextoSeleccionado: String = ""
    var colorListaTexto: String = ""
    var colorListaHover: String = ""
    var colorIconoCalendario: String = ""
    var coloresCalendario = FGCalendarioConfig()
    var colorScroll: String = ""

    // Botones
    var botonCancelar = FGButton5Config()
    var botonModificar = FGButton5Config()

    // Placeholder selector
    var textoPreSeleccion: String = ""
}

// MARK: - Elemento 3: Sección Agregar Carga

struct FGSeccionAgregarConfig {
    // Título modal
    var titulo: String = ""
    var tituloAttr = FGTextAttributes()

    // Labels de campos (separados por ";"):
    // Identificacion;TipoAfiliado;Nombre;Apellido;FechaNacimiento;Correo;Telefono
    var labels: [String] = []
    var labelsAttr = FGTextAttributes()

    // Colores
    var colorAsterisco: String = ""
    var colorBordeCampo: String = ""
    var colorBordeSeleccionado: String = ""
    var colorTextoSeleccionado: String = ""
    var colorIconoCalendario: String = ""
    var coloresCalendario = FGCalendarioConfig()
    var colorScroll: String = ""

    // Botones
    var botonCancelar = FGButton5Config()
    var botonAgregar = FGButton5Config()

    // Spinner
    var colorSpinner: String = ""
}

// MARK: - Elemento 4: Sección Over-Limit (Eliminar Carga)

struct FGSeccionOverLimitConfig {
    var titulo: String = ""
    var tituloAttr = FGTextAttributes()
    // Texto con "/" como placeholder para conteos dinámicos
    var texto: String = ""
    var textoAttr = FGTextAttributes()
}

// MARK: - Elemento 5: PopUp Eliminar Carga

struct FGPopupEliminarConfig {
    var iconUrl: String = ""
    var titulo: String = ""
    var tituloAttr = FGTextAttributes()
    // Texto con soporte **bold** (parseSalesforceText)
    var texto: String = ""
    var textoAttr = FGTextAttributes()
    // Botones Sí / No (button3)
    var botonSi = FGButtonConfig()
    var botonNo = FGButtonConfig()
}

// MARK: - Elemento 6: BackArrow

struct FGBackArrowConfig {
    var colorBackArrow: String = ""
}

// MARK: - Elemento 7: Fondo Avatar

struct FGFondoAvatarConfig {
    var colorFondoAvatar: String = ""
}

// MARK: - Estado completo

struct FamilyGroupUIState {
    var seccionPrincipal = FGSeccionPrincipalConfig()
    var seccionModificar = FGSeccionModificarConfig()
    var seccionAgregar = FGSeccionAgregarConfig()
    var seccionOverLimit = FGSeccionOverLimitConfig()
    var popupEliminar = FGPopupEliminarConfig()
    var backArrow = FGBackArrowConfig()
    var fondoAvatar = FGFondoAvatarConfig()
}
