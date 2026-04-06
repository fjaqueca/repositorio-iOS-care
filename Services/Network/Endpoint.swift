//
//  Endpoint.swift
//  CareAssistance
//
//  Created by Lara Dubs on 13/09/2022.
//

import Foundation

struct Endpoint {
    public let urlString: String
    public let keyEncodingStrategy: JSONDecoder.KeyDecodingStrategy

    public init(_ urlString: String, keyEncodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) {
        self.urlString = urlString
        self.keyEncodingStrategy = keyEncodingStrategy
    }

    static var rutValidate: Self {
        .init("get_rut_verification")
    }
    
    static var rutCognitoValidate: Self {
        .init("check_cognito_user_exists")
    }
    
    static var codeGenerate: Self {
        .init("gen_validation_code")
    }
    
    static var codeValidate: Self {
        .init("check_validation_code")
    }
    
    static var signUp: Self {
        .init("sign_up")
    }
    
    static var signUpForm: Self {
        .init("sign_up_form")
    }

    static var signUpFormEnterprises: Self {
        .init("get_enterprises?empresa")
    }
        
    static var signUpFormRoles: Self {
        .init("get_roles")
    }
    
    static var signUpFormCountries: Self {
        .init("get_paises")
    }
    
    static var signUpSetContactInfo: Self {
        .init("set_email_phone")
    }

    static var signIn: Self {
        .init("sign_in")
    }
    
    static var passwordRenew: Self {
        .init("get_renew_password")
    }
    
    static var passwordChange: Self {
        .init("change_password")
    }
    
    static var deleteAccount: Self {
        .init("delete_account")
    }

    static var profile: Self {
        .init("get_account_settings_r1")
    }
    
    static var profileUpdate: Self {
        .init("set_account_settings", keyEncodingStrategy: .useDefaultKeys)
    }
    
    static var logout: Self {
        .init("close_session")
    }
    
    static var clinics: Self {
        .init("get_clinicas_r1")
    }
    
    static var clinicDetails: Self {
        .init("get_clinica_details")
    }
    
    static var appointments: Self {
        .init("get_next_appointments")
    }
    
    static var professionals: Self {
        .init("get_professionals")
    }
    
    static var professionalsAvailability: Self {
        .init("get_professionals_availability", keyEncodingStrategy: .useDefaultKeys)
    }

    static var appointmentCreate: Self {
        .init("post_appointment")
    }
    
    static var appointmentUpdate: Self {
        .init("update_appointment")
    }
    
    static var enterprises: Self {
        .init("get_user_enterprises")
    }

    static var videoCallToken: Self {
        .init("create_twilio_token")
    }
    
    
    static var videoCallnOnDemandTokenR1: Self {
        .init("post_agent_work_queue")
    }
    
    static var videoCallnOnDemandQueuR1: Self {
        .init("get_task_queue_info_r1")
    }
    
    static var videoCallnOnDemandDequeueR1: Self {
        .init("update_task")
    }
    static var videoCallOnDemandRoomR1: Self {
        .init("twilio/get_room_info")
    }
    
    static var videoCallnOnDemandTokenNewR1: Self {
        .init("twilio/on_demand_new")
    }
    
    static var legals: Self {
        .init("get_politicas_r1")
    }
    
    static var promotions: Self {
        .init("get_banners")
    }
    
    static var api: Self {
        .init("get_api_versions")
    }
    
    static var medicalExams: Self {
        .init("get_medical_exam")
    }
    static var programs: Self {
        .init("get_programs")
    }
    static var stages: Self {
        .init("get_program_details_etapas")
    }
    static var tasks: Self {
        .init("get_caso_details_tarea")
    }
    static var activities: Self {
        .init("get_goal_details_actividades")
    }
    static var activityCompletion: Self {
        .init("get_task_details_completion")
    }
    static var stageGoalsActivityComplition: Self {
        .init("get_actividad_goal_details")
    }
    static var prescriptions: Self {
        .init("get_recetas")
    }
    static var repeatPrescription: Self {
        .init("post_repetir_receta")
    }
    static var exams: Self {
        .init("get_examenes_r1")
    }
    static var postExams: Self {
        .init("post_examen")
    }
    static var sendS3: Self {
        .init("send_file_to_s3")
    }
    static var postTask: Self {
        .init("post_task")
    }
    static var postFavorite: Self {
        .init("post_favoritos")
    }
    static var getBrandAccount: Self {
        .init("get_brand_account_r1")
    }
    static var postCompletado: Self {
        .init("post_completado")
    }
    static var getFavoriteTask: Self {
        .init("get_favorite_tasks")
    }
    static var getEducationalMaterial: Self {
        .init("get_material_educativo")
    }
    static var functionFlows: Self {
        .init("function_flows?api_name=Servicio_Generico__c")
    }
    static var getFileFromS3: Self {
        .init("get_file_from_s3_other")
    }
    static var getPresignedUrl: Self {
        .init("get_ver_url_privada")
    }
    static var functionFilter: Self {
        .init("function_filter", keyEncodingStrategy: .useDefaultKeys)
    }
    static var automatedExamsGenerate: Self {
        .init("function_flows?api_name=Servicio_Generico__c")
    }
}
