//
//  ElementRowView.swift
//  CareAssistance
//
//  Created by Lara Dubs on 17/04/2023.
//

import SwiftUI
import Combine

struct ElementRowView: View {
    let activity: Activities.Activity
    @State private var isPresentingDetails = false
    @State var isSingleCompletion = false
    @State private var isOn: Bool = false
    @State private var answer: String = ""
    @State var pickerList: [String] = []
    @State var totalRepeatTask: Int = 0
    @State var countRepeatTask: Int = 0
    @State var isRecurrentTask: Bool = false
    @Binding var completionResponse: [String : String]
    @Binding var isLoadingTasks: Bool
    //@Binding var showAlertActivityReady: Bool
    @Binding var alertAuthEvent: AlertAuthElements?
    // ✅ FIX: El publisher viene del padre (ElementsView) para que publisher.send()
    // en ElementDetailsView burbujee hasta ElementsView y dispare su onReceive.
    // Antes era una instancia local propia → nadie la escuchaba → no navegaba al hacer OK.
    var publisher: PassthroughSubject<Void, Never>
    @Binding var isQuestionnaire: Bool
    @State var allActivities: Activities
    let programa_ID: String
    let puntosActivos: Bool
    let puntosObtener: Float
    let puntosAcumulados: Float
    @State var positionOfPicklist: Int = 0
    @State var numericNextQuestionnaireId: String = ""
    
    
    @State private var selectedItems: [ChipItem] = []
    
    // ✅ NUEVO: Recibir estado de navegación del padre
    @EnvironmentObject var navigationState: NavigationState
    
    
    var body: some View {
        /*Button(action: {
            // ✅ NUEVA LÓGICA: Permitir entrar si hay concatenación activa
            let hasConcatenation = checkIfHasConcatenation()
            
            if !isSingleCompletion {
                if hasConcatenation {
                    // Tiene concatenación → Siempre permitir entrar para continuar el flujo
                    isPresentingDetails = true
                } else if countRepeatTask < totalRepeatTask {
                    // No tiene concatenación → Lógica normal
                    isPresentingDetails = true
                } else {
                    // Completado sin concatenación
                    //self.alertAuthEvent = .ActivityAllreadyDone
                    //self.showAlertActivityReady.toggle()
                }
            }
        })*/
        
        Button(action: {
            isPresentingDetails = true
        }) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack{
                            Text(activity.nombrePersonalizadoC ?? "Sin nombre")
                                .font(.appSmallMedium)
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.leading)
                            if isRecurrentTask{
                                Text("\(countRepeatTask)/\(totalRepeatTask)")
                                    .font(.appSmallMedium)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        Text(activity.descripcionCortaC ?? "Sin descripcion")
                            .font(.appCaption)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    if isSingleCompletion && countRepeatTask < totalRepeatTask{
                        if let completions = activity.taskCompletionTemplateR?.records {
                            ForEach(completions, id: \.self) { com in
                                if com.tipoDeDatosC == "Checkbox"{
                                    CheckBoxRow(
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        isRequired: com.requeridoC ?? false,
                                        response: $completionResponse,
                                        canEdit: com.editableC ?? false
                                    )


                                    if completionResponse[com.Id ?? ""] != "true" {
                                        Text("Este campo es obligatorio")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }

                                }
                                if com.tipoDeDatosC == "Número"{
                                    NumericRow(
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        isRequired: com.requeridoC ?? false,
                                        response: $completionResponse,
                                        numericNextQuestionnaireId: $numericNextQuestionnaireId,
                                        conditionsOfNumericQuestionnaire: com.posiblesValoresC,
                                        possibilityOfId: com.concatenacionPicklistEnrolamientoC,
                                        canEdit: com.editableC ?? false
                                    )
                                }
                                if com.tipoDeDatosC == "Subir Archivo"{
                                    FileRow(
                                        showDescription: true,
                                        instrucciones: com.posiblesValoresC ?? "",
                                        response: $completionResponse,
                                        idCom: com.Id ?? "",
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        subname: com.tipoDeDatosC ?? "Sin Nombre",
                                        isRequired: com.requeridoC ?? false
                                    )
                                    // 🔴 TEXTO DE ERROR
                                        if completionResponse[com.Id ?? ""] == nil ||
                                           completionResponse[com.Id ?? ""]?.isEmpty == true {
                                            Text("Este campo es obligatorio")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                                .transition(.opacity)
                                        }
                                    
                                }
                                /*if com.tipoDeDatosC == "Texto URL (Archivo multimedia)"{
                                    OpenURLRow(
                                        response: $completionResponse,
                                        name: com.nombrePersonalizadoC ?? "",
                                        idCom: com.Id ?? "",
                                        url: com.posiblesValoresC ?? ""
                                    )
                                }*/
                                if com.tipoDeDatosC == "Texto URL (Archivo multimedia)" {
                                    OpenURLRow(
                                        response: $completionResponse,
                                        name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                        idCom: com.Id ?? "",
                                        url: com.posiblesValoresC ?? "",
                                        isRequired: com.requeridoC ?? false,
                                        canEditToggle: com.editableC ?? false
                                    )
                                }

                            }
                        }
                    }
                    
                    if puntosActivos {
                        Text(activity.puntosDeLaActividadC ?? 0 > 1 ? "\(Int(activity.puntosDeLaActividadC ?? 0)) pts" : "\(Int(activity.puntosDeLaActividadC ?? 0)) pt")
                            .font(.appSmallMedium)
                            .foregroundColor(.primaryText)
                    }

                }
                
                if isSingleCompletion && countRepeatTask < totalRepeatTask{
                    if let completions = activity.taskCompletionTemplateR?.records {
                        ForEach(completions, id: \.self) { com in
                            if com.tipoDeDatosC == "Picklist"{
                                PickerRow(
                                    dataPicker: com.posiblesValoresC ?? "",
                                    idCom: com.Id ?? "",
                                    name: com.nombrePersonalizadoC ?? "Sin Nombre",
                                    isRequired: com.requeridoC ?? false,
                                    response: $completionResponse,
                                    positionOfPicklist: $positionOfPicklist,
                                    canEdit: com.editableC ?? false
                                )
                            }
                            if com.tipoDeDatosC == "Picklist Múltiple"{
                                /*MultiPickerRow(
                                    dataMultiPicker: com.posiblesValoresC ?? "",
                                    response: $completionResponse,
                                    idCom: com.Id ?? "",
                                    name: com.nombrePersonalizadoC ?? ""
                                )*/
                                /*ChipPicker(
                                    title: "Selecciona tus gustos",
                                    options: allInterests,
                                    selections: $userInterests
                                )
                                .frame(minHeight: 300) // Damos espacio para el FlowLayout
                                .padding(.vertical, 10)*/
                                MultiSelectField(
                                      label: "Habilidades Técnicas",
                                      placeholder: "Selecciona una o más opciones",
                                      selectedItems: $selectedItems,
                                      allOptions: com.posiblesValoresC ?? "",
                                      isRequired: com.requeridoC ?? false,
                                      isValid: !(completionResponse[com.Id ?? ""]?.isEmpty ?? true),
                                      canEdit: com.editableC ?? false
                                  )
                            }
                            if com.tipoDeDatosC == "Texto"{
                                CommentRow(
                                    isRequired: com.requeridoC ?? false,
                                    response: $completionResponse,
                                    idCom: com.Id ?? "",
                                    name: com.nombrePersonalizadoC ?? "",
                                    canEdit: com.editableC ?? false
                                )
                            }
                            
                        }
                    }
                }
                
                
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.margin)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(Color.grayLight, lineWidth: 1)
                    .shadow(color: .shadowLight, radius: 1, x: 1,y: 1)
            )
            .background(isSingleCompletion ? Color.clear : Color.buttonPrimaryBackground.opacity(0.3))
            .cornerRadius(.cornerRadius)
            
        }
        //.opacity(shouldShowAsDisabled() ? 0.5 : 1)
        .onAppear{
            recurrentTask()
            
        }
        .padding(.vertical, .margin / 2)
        
        .navigationLink(isActive: $isPresentingDetails) {
            if let completion = activity.taskCompletionTemplateR{
                ElementDetailsView(
                    activityName: activity.nombrePersonalizadoC ?? "Sin nombre",
                    activityInstruction: activity.instruccionesC ?? "Sin intrucciones",
                    completion: completion,
                    activity: activity,
                    isLoadingTasks: $isLoadingTasks,
                    publisher: self.publisher,
                    isQuestionnaire: $isQuestionnaire,
                    activities: allActivities,
                    program_ID: programa_ID,
                    puntosActivos: puntosActivos,
                    puntosObtener: puntosObtener,
                    puntosAcumulados: puntosAcumulados
                )
                .environmentObject(navigationState)  // ✅ PASAR ESTADO
            }
            
        }
    }
    func recurrentTask(){
        self.countRepeatTask = Int((activity.cantTaskCompletionC ?? 0) / (activity.totalTaskComTemplateC ?? 1))
        self.totalRepeatTask = Int((activity.totalTaskCompletion2C ?? 0) / (activity.totalTaskComTemplateC ?? 1))
        if totalRepeatTask > 1{
            isRecurrentTask = true
        }
    }
    
    // ✅ NUEVA FUNCIÓN: Verificar si esta actividad tiene concatenación
    func checkIfHasConcatenation() -> Bool {
        // 1. Verificar concatenación de Picklist (a nivel de Template)
        if let templates = activity.taskCompletionTemplateR?.records {
            for template in templates {
                if template.tipoDeDatosC == "Picklist",
                   let concatenacion = template.concatenacionPicklistEnrolamientoC,
                   !concatenacion.isEmpty {
                    print("✅ Actividad \(activity.Id ?? "") tiene concatenación de Picklist")
                    return true
                }
            }
        }
        
        // 2. Verificar concatenación de Actividad
        if let nextActivityId = activity.idActividadConcatenadaEnrolamientoC,
           !nextActivityId.isEmpty {
            print("✅ Actividad \(activity.Id ?? "") tiene concatenación de Actividad")
            return true
        }
        
        // 3. Verificar si es parte de una concatenación (otras actividades apuntan a esta)
        if let allActs = allActivities.records {
            for otherActivity in allActs {
                // Verificar si alguna actividad tiene a esta en su concatenación
                if let nextId = otherActivity.idActividadConcatenadaEnrolamientoC,
                   nextId == activity.Id {
                    print("✅ Actividad \(activity.Id ?? "") es destino de concatenación")
                    return true
                }
                
                // Verificar concatenación de Picklist
                if let templates = otherActivity.taskCompletionTemplateR?.records {
                    for template in templates {
                        if let concatenacion = template.concatenacionPicklistEnrolamientoC,
                           concatenacion.contains(activity.Id ?? "") {
                            print("✅ Actividad \(activity.Id ?? "") está en concatenación de Picklist")
                            return true
                        }
                    }
                }
            }
        }
        
        print("⚠️ Actividad \(activity.Id ?? "") NO tiene concatenación")
        return false
    }
}

