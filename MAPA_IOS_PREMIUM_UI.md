# MAPA iOS — Premium UI / App con Vida

Mapa exhaustivo de situaciones donde aplicar el toolkit premium para que la app se sienta viva, profesional y con personalidad propia.

**Toolkit disponible:** Lottie, ShimmerModifier, SkeletonView, HapticManager, SpringModifiers, TooltipView, ConfettiModifier + nativos SwiftUI (matchedGeometryEffect, transitions, GeometryReader)

---

## 1. Estados de carga (loading)

| Situacion | Toolkit iOS |
|---|---|
| Carga inicial de pantalla | SkeletonList / SkeletonCard |
| Carga de lista (Programas, Examenes, Recetas, Citas, Material Educativo, Etapas) | SkeletonList / SkeletonRow |
| Pull-to-refresh | SkeletonList (reemplaza contenido mientras recarga) |
| Paginacion / infinite scroll | SkeletonRow al final de la lista |
| Aplicar filtro o buscar | SkeletonList (reemplaza resultados viejos) |
| Carga de detalle al tocar un item | SkeletonCard |
| Carga de imagen (avatar, foto de programa, banner) | SkeletonCircle / SkeletonBlock + .shimmer() |
| Carga de PDF / documento | SkeletonBlock grande + .shimmer() |
| "Procesando..." despues de submit | Boton en estado pending con .shimmer() o Lottie loader inline |
| Sincronizacion en background | Badge sutil con .shimmer() |

---

## 2. Empty states

| Situacion | Toolkit iOS |
|---|---|
| Lista global vacia (sin programas, sin citas, sin examenes) | Lottie animado + texto descriptivo |
| Busqueda sin resultados | Lottie animado + texto |
| Filtro sin resultados | Lottie animado + texto |
| Bandeja sin notificaciones | Lottie animado + texto |
| Sin historial / sin actividad reciente | Lottie animado + texto |
| "Aun no has completado ninguna tarea" | Lottie animado + texto motivacional |
| Galeria de archivos vacia | Lottie animado + texto |
| Chat / mensajes sin contenido | Lottie animado + texto |

---

## 3. Estados de error

| Situacion | Toolkit iOS |
|---|---|
| Sin conexion a internet | Lottie error + .popIn() |
| Timeout de servicio | Lottie error + boton reintentar .bounceOnTap() |
| Error 500 / servidor caido | Lottie error + texto descriptivo |
| 404 / recurso no encontrado | Lottie error + .fadeSlideIn() |
| Error de validacion de formulario | HapticManager.error() + shake animation |
| Permisos denegados (camara, mic, ubicacion, notif) | Lottie explicativo + tooltip |
| Sesion expirada | Lottie + transicion a login |
| Version obsoleta / force update | Lottie + modal bloqueante |
| Error al subir archivo | HapticManager.error() + Lottie |
| Error al descargar PDF | HapticManager.error() + tooltip con instrucciones |
| Error al iniciar videollamada | Lottie error + boton reintentar |

**NUNCA confetti en errores.**

---

## 4. Estados de exito

| Situacion | Toolkit iOS |
|---|---|
| Cita agendada | Lottie checkmark + HapticManager.success() + .popIn() |
| Cita reagendada / cancelada con exito | Lottie check + HapticManager.success() |
| Formulario / encuesta enviado | Lottie success + HapticManager.success() |
| Tarea de programa completada | Lottie check + HapticManager.success() |
| Examen subido | Lottie success + HapticManager.success() |
| Receta descargada | HapticManager.success() + toast animado |
| Foto de perfil actualizada | HapticManager.success() + .popIn() |
| Contrasena cambiada | Lottie check + HapticManager.success() |
| Datos personales guardados | HapticManager.success() |
| Mensaje enviado al medico | HapticManager.success() + .springOnAppear() |
| Pago procesado (si aplica) | Lottie success + HapticManager.success() |
| Permiso concedido | HapticManager.success() |

---

## 5. Hitos / celebraciones (Confetti territory)

| Situacion | Toolkit iOS |
|---|---|
| Primera tarea completada | .confetti() + Lottie + HapticManager.success() |
| Programa de salud terminado | .confetti() + Lottie celebracion + HapticManager.success() |
| Etapa completa | .confetti() + Lottie + HapticManager.success() |
| Racha de adherencia (X dias seguidos) | .confetti() + Lottie + HapticManager.success() |
| Primera cita agendada en la app | .confetti() + Lottie |
| Onboarding finalizado | .confetti() sutil |
| Cumpleanos del usuario | .confetti() + Lottie birthday |
| Logro / badge desbloqueado | .confetti() + Lottie unlock + .popIn() |
| Examen completado (proceso completo) | .confetti() + Lottie |
| Aniversario en la app | .confetti() + Lottie |

---

## 6. Transiciones entre pantallas

| Situacion | Toolkit iOS |
|---|---|
| Lista a detalle (Programa, Examen, Receta, Cita) | matchedGeometryEffect (hero transition) |
| Tarjeta a vista expandida (hero image) | matchedGeometryEffect |
| Tab a tab (Home, Citas, Salud, Perfil) | .transition(.opacity) suave |
| Stepper / wizard (registro RUT a datos a confirmacion) | .transition(.asymmetric) con slide |
| Onboarding entre slides | TabView con spring |
| Login a Home | .transition(.scale.combined(with: .opacity)) |
| Modal abrir/cerrar | .spring() en presentacion |
| Bottom sheet entrar/salir | .spring(response: 0.3, dampingFraction: 0.8) |
| Pop de back | misma transicion que la entrada, invertida |

---

## 7. Microinteracciones (taps, gestos, toggles)

| Situacion | Toolkit iOS |
|---|---|
| Press de boton primario | .bounceOnTap() + HapticManager.impact(style: .medium) |
| Tap en card de lista | .pressable() + HapticManager.impact(style: .light) |
| Toggle on/off | HapticManager.selection() + .spring() |
| Switch / checkbox / radio | HapticManager.selection() |
| Marcar favorito (corazon anim) | Lottie heart + HapticManager.impact(style: .light) |
| Long press (seleccion multiple, copiar) | HapticManager.impact(style: .heavy) |
| Swipe-to-delete / swipe-to-action | HapticManager.warning() al llegar al threshold |
| Pull to dismiss en bottom sheet | HapticManager.impact(style: .light) al soltar |
| Slider de rango (dolor 0-10, satisfaccion) | HapticManager.selection() en cada step |
| Stepper (+/-) | HapticManager.impact(style: .light) |
| Rating estrellas | HapticManager.selection() + .spring() en cada estrella |

---

## 8. Feedback en formularios

| Situacion | Toolkit iOS |
|---|---|
| Focus en campo (border anim, label flotante) | .spring() en border color + label offset |
| Validacion en vivo (RUT, email, telefono) | Color border animado + Lottie check verde inline |
| Mostrar/ocultar contrasena | .spring() en icono ojo |
| Indicador de fortaleza de contrasena | Barra animada con colores + .spring() |
| Contador de caracteres | Color cambia con .animation() |
| Campo requerido vacio al submit | Shake animation + HapticManager.error() + border rojo |
| Auto-formato (RUT con guion, telefono con espacios) | Transicion suave del texto |
| Match de campos (contrasena vs confirmar) | Check verde animado al coincidir |
| DatePicker / TimePicker | HapticManager.selection() al cambiar |
| Bottom sheet selector | .spring() al abrir + HapticManager.selection() |
| OTP / codigo de verificacion | Auto-focus animado entre campos + HapticManager.selection() |

---

## 9. Cambios de estado en tiempo real

| Situacion | Toolkit iOS |
|---|---|
| Online a offline | Banner .springOnAppear() desde arriba (rojo) |
| Reconexion exitosa | Banner verde fugaz .fadeSlideIn() + auto-dismiss |
| Sync en progreso a completo | .shimmer() a contenido real (transicion atomica) |
| Cita "pendiente" a "confirmada" | Badge con .popIn() + HapticManager.success() |
| Receta "lista para retirar" a "retirada" | Color change animado |
| Notificacion leida a no leida | Badge .popIn() |
| Mensaje nuevo entrando al chat | .springOnAppear() desde abajo |
| Estado de videollamada (esperando a conectando a en llamada) | Lottie por estado |

---

## 10. Onboarding / feature discovery

| Situacion | Toolkit iOS |
|---|---|
| Primer login (tour por la app) | .spotlight() secuencial sobre elementos clave |
| Primera vez en seccion Programas | .tooltip() sobre el primer programa |
| Primera vez agendando una cita | .spotlight() sobre boton de agendar |
| Nuevo feature despues de update | .tooltip() highlight |
| Hint de gesto ("desliza para ver mas") | .tooltip() con texto + Lottie swipe |
| Tooltip contextual ("toca tu version para ver novedades") | .tooltip() en chip de version |
| Walkthrough multi-paso | .spotlight() encadenados |
| "Sabias que..." cards | .popIn() + .pressable() |

---

## 11. Bienvenida y saludos

| Situacion | Toolkit iOS |
|---|---|
| Splash screen (logo anim breve) | Lottie logo animado |
| "Hola, [nombre]" en Home segun hora del dia | .fadeSlideIn() + texto dinamico |
| Welcome animation post-login | Lottie + .springOnAppear() en cascada |
| Greeting card del dia | .popIn() + .pressable() |
| Mensaje motivacional (programa de salud) | .fadeSlideIn() |
| Saludo personalizado por brand/convenio | Lottie brand-specific |

---

## 12. Notificaciones / alertas in-app

| Situacion | Toolkit iOS |
|---|---|
| Toast/snackbar de confirmacion | .springOnAppear() desde abajo + auto-dismiss |
| Banner de alerta (cita proxima, medicamento) | .springOnAppear() desde arriba |
| In-app notification (top sheet) | .fadeSlideIn(from: .top) |
| Update disponible | Modal con Lottie + .popIn() |
| Conexion perdida | Banner rojo .springOnAppear() |
| Permiso requerido | .tooltip() contextual |
| Mensaje del medico nuevo | Badge .popIn() + HapticManager.success() |
| Recordatorio antes de videollamada | Banner con Lottie + countdown |

---

## 13. Listas con CRUD visual

| Situacion | Toolkit iOS |
|---|---|
| Item entrando a la lista (recien creado) | .springOnAppear() + highlight fugaz |
| Item saliendo (eliminado) | .transition(.slide) + HapticManager.warning() |
| Item actualizado (highlight fugaz) | Flash de color con .animation() |
| Reordenamiento por drag | HapticManager.impact(style: .medium) |
| Modo seleccion multiple (entrar/salir) | .spring() en checkboxes |
| Bulk actions (eliminar varios) | HapticManager.warning() |
| Item destacado / pinned | .popIn() en icono pin |

---

## 14. Detalle de item / hero

| Situacion | Toolkit iOS |
|---|---|
| Hero image transition (lista a detalle) | matchedGeometryEffect |
| Header colapsable (parallax) | GeometryReader + .spring() |
| Tabs internas (info, comentarios, archivos) | .spring() en indicador de tab |
| Carrusel de imagenes | .spring() en paginacion |
| Acciones flotantes (compartir, favorito, descargar) | .popIn() escalonado |
| Read more / expandir descripcion | .spring() en altura + .fadeSlideIn() del texto |
| Galeria full-screen al tap | matchedGeometryEffect |

---

## 15. Multimedia

| Situacion | Toolkit iOS |
|---|---|
| Video player (controles fade) | .transition(.opacity) |
| Buffering | Lottie loader custom |
| Cargar imagen (placeholder a reveal) | SkeletonBlock + .shimmer() a imagen real |
| Camara (shutter anim) | HapticManager.impact(style: .heavy) + flash |
| Audio recording (waveform) | Lottie waveform |
| Subida de archivo (progress real) | Barra animada con .spring() |
| Visualizar PDF (zoom, swipe paginas) | .spring() en zoom |
| Galeria con grid | .springOnAppear() escalonado |

---

## 16. Permisos

| Situacion | Toolkit iOS |
|---|---|
| Pre-prompt explicativo (antes del system dialog) | Lottie ilustrativo + .popIn() |
| "Permiso denegado, ve a settings" | .tooltip() con link a Settings |
| Camara para foto de perfil | Lottie camara |
| Microfono para videoconsulta | Lottie mic |
| Notificaciones push | Lottie notificacion |
| Ubicacion (encontrar clinica cercana) | Lottie mapa |

---

## 17. Lifecycle y conexion

| Situacion | Toolkit iOS |
|---|---|
| App vuelve del background (refresh sutil) | .shimmer() breve + refresh datos |
| Force update (modal bloqueante) | Lottie + modal sin dismiss |
| Logout (transicion a login) | .transition(.opacity) |
| Token expirado a re-login | Transicion suave a onboarding |
| Mantenimiento programado | Lottie mantenimiento + texto |
| Cambio de brand/convenio | Transition completa |

---

## 18. Especificas de salud (contexto CareAssistance)

| Situacion | Toolkit iOS |
|---|---|
| Recordatorio de medicamento (snooze, tomado, omitido) | Lottie pill + HapticManager.selection() por accion |
| Adherencia a programa (grafico animado) | .spring() en progreso circular |
| Resultado de examen disponible (badge anim) | .popIn() en badge + HapticManager.success() |
| Cita proxima (countdown / urgencia visual) | Color pulsante con .animation(.easeInOut.repeatForever()) |
| Sala de espera de videollamada | Lottie "esperando" loop |
| Llamada entrante de doctor | Lottie phone + HapticManager.impact(style: .heavy) |
| Encuesta post-consulta | .springOnAppear() escalonado en preguntas |
| Triaje / sintomas (selector visual) | .pressable() en opciones + HapticManager.selection() |
| Calendario de citas (transicion mes a mes) | .transition(.slide) entre meses |
| Mapa de clinica (pin animado) | .popIn() en pines |
| Tarjeta de paciente / credencial (flip) | rotation3DEffect con .spring() |
| Programa de salud completado (certificado anim) | Lottie certificado + .confetti() |
| Score de bienestar (gauge animado) | .spring() en gauge circular |

---

## 19. Busqueda

| Situacion | Toolkit iOS |
|---|---|
| Typing (clear button aparece) | .popIn() en boton clear |
| Sugerencias en vivo | .fadeSlideIn() escalonado |
| Busquedas recientes | .springOnAppear() |
| Filtros expandibles | .spring() en altura |
| Resultados aparecen en cascada | .springOnAppear() con delay por indice |
| Sin resultados (empty state diferenciado) | Lottie busqueda vacia |

---

## 20. Logros y gamificacion (futuro)

| Situacion | Toolkit iOS |
|---|---|
| Badge desbloqueado | .confetti() + Lottie unlock + .popIn() |
| Progreso visual de programa (anillo) | .spring() en anillo circular |
| Streak/racha dias seguidos | Lottie fuego + .popIn() |
| Nivel subido | .confetti() + Lottie level up |
| Comparativa con metas | .spring() en barras de progreso |

---

## Priorizacion recomendada

### Fase 1 — Quick wins (alto impacto, bajo esfuerzo)
1. Skeleton en las 4 listas principales (Programas, Examenes, Recetas, Citas)
2. Empty states con Lottie en esas 4 vistas
3. Haptics en botones de accion (agendar, enviar, confirmar)
4. .bounceOnTap() y .pressable() en botones y cards
5. Confetti al completar tarea/programa

### Fase 2 — Flujo completo premium
6. Modernizar un flujo entero (ej: agendar cita inicio a fin)
7. Spring animations en entradas de listas (.springOnAppear escalonado)
8. Transiciones entre lista a detalle (matchedGeometryEffect)
9. Feedback en formularios (shake, validacion visual)

### Fase 3 — Diferenciadores
10. Spotlight/tooltips para features nuevas
11. Estados de exito con Lottie
12. Bienvenida personalizada en Home
13. Animaciones especificas de salud (punto 18)

### Fase 4 — Pulido continuo
14. Microinteracciones (punto 7) al tocar otras vistas
15. Notificaciones in-app animadas
16. Busqueda con cascada
17. Gamificacion y logros (punto 20)
