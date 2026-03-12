//
//  ClinicDetail.swift
//  CareAssistance
//
//  Created by Lara Dubs on 30/12/2022.
//

import RealmSwift

class ClinicDetail: Object, ObjectKeyIdentifiable, Decodable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var descShort: String?
    @Persisted var descLong: String?
    @Persisted var brandUrl: String?
    @Persisted var icon: String?
    @Persisted var phoneNumber: String?
    @Persisted var whatsapp: String?
    @Persisted var brandBanner: String?
    @Persisted var fondoOndemand: String?
    @Persisted var twilioFlexId: String?
    @Persisted var videocallAvalible: String?
    @Persisted var appointmentAvalible: String?
    @Persisted var dinamicButton: String?
    @Persisted var textPopup: String?
    @Persisted var atrTextPopup: String?
}
