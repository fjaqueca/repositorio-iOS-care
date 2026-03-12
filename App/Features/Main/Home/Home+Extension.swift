//
//  Home+Extension.swift
//  CareAssistance
//
//  Created by The App Master on 18/01/2024.
//

import Foundation

extension HomeView {
    func loadUIState(){
                if let record = self.items.first?.records{
                    for brandAccount in record{
                        //MARK: - Tipe Home
                        if tipeSubHome.count == 0{
                            if brandAccount.Name == "Home"{
                                self.UIState.imageLogo = brandAccount.valor11C ?? ""
                                //MARK: - GreetingsConfig
                                self.UIState.greetingUIState.text = brandAccount.valor21C ?? "Hola "
                                if brandAccount.valor22C == "firasans_regular" {
                                    self.UIState.greetingUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor22C == "firasans_bold" {
                                    self.UIState.greetingUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor22C == "firasans_italic" {
                                    self.UIState.greetingUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.greetingUIState.color = brandAccount.valor23C ?? "#0082C7"
                                self.UIState.greetingUIState.size = brandAccount.valor24C ?? "14"
                                //MARK: - UserNameConfig
                                if brandAccount.valor31C == "firasans_regular" {
                                    self.UIState.userUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor31C == "firasans_bold" {
                                    self.UIState.userUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor31C == "firasans_italic" {
                                    self.UIState.userUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.userUIState.color = brandAccount.valor32C ?? "#004A99"
                                self.UIState.userUIState.size = brandAccount.valor33C ?? "16"
                                //MARK: - UserPointConfig
                                self.UIState.userPointUIState.background = brandAccount.valor41C ?? "#004A99"
                                self.UIState.userPointUIState.color = brandAccount.valor42C ?? "#FFFFFF"
                                self.UIState.userPointUIState.size = brandAccount.valor43C ?? "15"
                                //MARK: - NotificationConfig
                                self.UIState.notificationUIState.URLWithoutNotification = brandAccount.valor51C ?? "haveNotification"
                                self.UIState.notificationUIState.URLWithNotification = brandAccount.valor52C ?? ""
                                //MARK: - BannersConfig
                                self.UIState.bannersUIState.URLBanner1 = brandAccount.atributo61C ?? ""
                                self.UIState.bannersUIState.URLBanner2 = brandAccount.atributo62C ?? ""
                                self.UIState.bannersUIState.URLBanner3 = brandAccount.atributo63C ?? ""
                                self.UIState.bannersUIState.URLBanner4 = brandAccount.atributo64C ?? ""
                                self.UIState.bannersUIState.URLBanner5 = brandAccount.atributo65C ?? ""
                                self.UIState.bannersUIState.URLBanner6 = brandAccount.atributo66C ?? ""
                                self.UIState.bannersUIState.URLValor1 = brandAccount.valor61C ?? ""
                                self.UIState.bannersUIState.URLValor2 = brandAccount.valor62C ?? ""
                                self.UIState.bannersUIState.URLValor3 = brandAccount.valor63C ?? ""
                                self.UIState.bannersUIState.URLValor4 = brandAccount.valor64C ?? ""
                                self.UIState.bannersUIState.URLValor5 = brandAccount.valor65C ?? ""
                                self.UIState.bannersUIState.URLValor6 = brandAccount.valor66C ?? ""
                                //MARK: - LabelClinicConfig
                                self.UIState.firstLabelUIState.text = brandAccount.valor71C ?? "Clinicas"
                                if brandAccount.valor72C == "firasans_regular" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor72C == "firasans_bold" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor72C == "firasans_italic" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.firstLabelUIState.color = brandAccount.valor73C ?? "#004A99"
                                self.UIState.firstLabelUIState.size = brandAccount.valor74C ?? "18"
                                //MARK: - LabelSeeAllConfig
                                self.UIState.labelSeeAllUIState.text = brandAccount.valor81C ?? "Ver todo"
                                if brandAccount.valor82C == "firasans_regular" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor82C == "firasans_bold" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor82C == "firasans_italic" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelSeeAllUIState.color = brandAccount.valor83C ?? "#0082C7"
                                self.UIState.labelSeeAllUIState.size = brandAccount.valor84C ?? "15"
                                self.UIState.labelSeeAllUIState.title.text = brandAccount.valor85C ?? "Clinicas"
                                if let valor = brandAccount.valor86C?.components(separatedBy: ";"), valor.count >= 3{
                                    self.UIState.labelSeeAllUIState.title.colorText = valor[0]
                                    self.UIState.labelSeeAllUIState.title.sizeText = valor[1]
                                    if valor[2] == "firasans_regular" {
                                        self.UIState.labelSeeAllUIState.title.font = "FiraSans-Regular"
                                    }
                                    if valor[2] == "firasans_bold" {
                                        self.UIState.labelSeeAllUIState.title.font = "FiraSans-Bold"
                                    }
                                    if valor[2] == "firasans_italic" {
                                        self.UIState.labelSeeAllUIState.title.font = "FiraSans-Italic"
                                    }
                                }
                                //MARK: - LabelTaskConfig
                                self.UIState.labelTaskUIState.text = brandAccount.valor91C ?? "Tareas"
                                if brandAccount.valor92C == "firasans_regular" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor92C == "firasans_bold" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor92C == "firasans_italic" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelTaskUIState.color = brandAccount.valor93C ?? "#004A99"
                                self.UIState.labelTaskUIState.size = brandAccount.valor94C ?? "18"
                                //MARK: - NavBar
                                self.selectedColor = brandAccount.valor101C ?? "#004A99"
                                self.UIState.navBar.navBarColor = brandAccount.valor101C ?? ""
                                self.UIState.navBar.iconsNavBar.home = brandAccount.valor102C ?? ""
                                self.UIState.navBar.iconsNavBar.program = brandAccount.valor103C ?? ""
                                self.UIState.navBar.iconsNavBar.diary = brandAccount.valor104C ?? ""
                                self.UIState.navBar.iconsNavBar.profile = brandAccount.valor105C ?? ""
                                self.UIState.navBar.iconsNavBar.more = brandAccount.valor106C ?? ""
                                self.UIState.navBar.iconsNavBar.exam = brandAccount.valor107C ?? ""
                                self.UIState.navBar.iconsNavBar.prescription = brandAccount.valor108C ?? ""
                                self.UIState.navBar.iconsNavBar.material = brandAccount.valor109C ?? ""
                                
                                if let valor = brandAccount.valor1010C?.components(separatedBy: ";"), valor.count >= 8{
                                    self.UIState.navBar.sectionNameNavbar.home = valor[0]
                                    self.UIState.navBar.sectionNameNavbar.program = valor[1]
                                    self.UIState.navBar.sectionNameNavbar.diary = valor[2]
                                    self.UIState.navBar.sectionNameNavbar.profile = valor[3]
                                    self.UIState.navBar.sectionNameNavbar.more = valor[4]
                                    self.UIState.navBar.sectionNameNavbar.exam = valor[5]
                                    self.UIState.navBar.sectionNameNavbar.prescription = valor[6]
                                    self.UIState.navBar.sectionNameNavbar.material = valor[7]
                                }else{
                                    self.UIState.navBar.sectionNameNavbar.home = ""
                                    self.UIState.navBar.sectionNameNavbar.program = ""
                                    self.UIState.navBar.sectionNameNavbar.diary = ""
                                    self.UIState.navBar.sectionNameNavbar.profile = ""
                                    self.UIState.navBar.sectionNameNavbar.more = ""
                                    self.UIState.navBar.sectionNameNavbar.exam = ""
                                    self.UIState.navBar.sectionNameNavbar.prescription = ""
                                    self.UIState.navBar.sectionNameNavbar.material = ""
                                }
                                
                                
                                //MARK: - PlaceholderAppointment
                                self.UIState.placerholderAppointment.background = brandAccount.Valor_11_1__c ?? "#F5F5F5"
                                self.UIState.placerholderAppointment.URLimg = brandAccount.Valor_11_2__c ?? "https://ca-backend-dev.s3.amazonaws.com/app/assets/fced2884-fd36-4874-84cd-8b6007e73add.png"
                                
                                //MARK: - NextAppointmentview
                                self.UIState.nextAppointmentUIState.backgrounOblea = brandAccount.valor121C ?? "#F9FBF6"
                                self.UIState.nextAppointmentUIState.headerOblea = brandAccount.valor122C ?? "#004A99"
                                if let titleInfo = brandAccount.valor123C {
                                    let arrayTitleInfo = titleInfo.components(separatedBy: ";")
                                    var x = 0
                                    for info in arrayTitleInfo {
                                        if x == 0 {
                                            self.UIState.nextAppointmentUIState.title.text = info
                                        }
                                        if x == 1 {
                                            if info == "firasans_regular" {
                                                self.UIState.nextAppointmentUIState.title.font = "FiraSans-Regular"
                                            }
                                            if info == "firasans_bold" {
                                                self.UIState.nextAppointmentUIState.title.font = "FiraSans-Bold"
                                            }
                                            if info == "firasans_italic" {
                                                self.UIState.nextAppointmentUIState.title.font = "FiraSans-Italic"
                                            }
                                        }
                                        if x == 2 {
                                            self.UIState.nextAppointmentUIState.title.color = info
                                        }
                                        if x == 3 {
                                            self.UIState.nextAppointmentUIState.title.size = info
                                        }
                                        x += 1
                                    }
                                }
                                if let clinicInfo = brandAccount.valor124C {
                                    let arrayClinicInfo = clinicInfo.components(separatedBy: ";")
                                    var x = 0
                                    for info in arrayClinicInfo {
                                        if x == 0 {
                                            if info == "firasans_regular" {
                                                self.UIState.nextAppointmentUIState.clinic.font = "FiraSans-Regular"
                                            }
                                            if info == "firasans_bold" {
                                                self.UIState.nextAppointmentUIState.clinic.font = "FiraSans-Bold"
                                            }
                                            if info == "firasans_italic" {
                                                self.UIState.nextAppointmentUIState.clinic.font = "FiraSans-Italic"
                                            }
                                        }
                                        if x == 1 {
                                            self.UIState.nextAppointmentUIState.clinic.color = info
                                        }
                                        if x == 2 {
                                            self.UIState.nextAppointmentUIState.clinic.size = info
                                        }
                                        x += 1
                                    }
                                }
                                if let dateInfo = brandAccount.valor125C {
                                    let arrayDateInfo = dateInfo.components(separatedBy: ";")
                                    var x = 0
                                    for info in arrayDateInfo {
                                        if x == 0 {
                                            if info == "firasans_regular" {
                                                self.UIState.nextAppointmentUIState.date.font = "FiraSans-Regular"
                                            }
                                            if info == "firasans_bold" {
                                                self.UIState.nextAppointmentUIState.date.font = "FiraSans-Bold"
                                            }
                                            if info == "firasans_italic" {
                                                self.UIState.nextAppointmentUIState.date.font = "FiraSans-Italic"
                                            }
                                        }
                                        if x == 1 {
                                            self.UIState.nextAppointmentUIState.date.color = info
                                        }
                                        if x == 2 {
                                            self.UIState.nextAppointmentUIState.date.size = info
                                        }
                                        x += 1
                                    }
                                }
                                if let hourInfo = brandAccount.valor126C {
                                    let arrayHourInfo = hourInfo.components(separatedBy: ";")
                                    var x = 0
                                    for info in arrayHourInfo {
                                        if x == 0 {
                                            if info == "firasans_regular" {
                                                self.UIState.nextAppointmentUIState.hour.font = "FiraSans-Regular"
                                            }
                                            if info == "firasans_bold" {
                                                self.UIState.nextAppointmentUIState.hour.font = "FiraSans-Bold"
                                            }
                                            if info == "firasans_italic" {
                                                self.UIState.nextAppointmentUIState.hour.font = "FiraSans-Italic"
                                            }
                                        }
                                        if x == 1 {
                                            self.UIState.nextAppointmentUIState.hour.color = info
                                        }
                                        if x == 2 {
                                            self.UIState.nextAppointmentUIState.hour.size = info
                                        }
                                        x += 1
                                    }
                                }
                            }

                        }
                        //MARK: - Tipe Sub Home 1
                        if tipeSubHome.last == 1 {
                            
                            if brandAccount.Name == (UIState.customSubHomeName.last ?? "SubHome1"){
                                //MARK: - GreetingsConfig
//                                print(brandAccount)
                                if brandAccount.valor11C == "firasans_regular" {
                                    self.UIState.greetingUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor11C == "firasans_bold" {
                                    self.UIState.greetingUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor11C == "firasans_italic" {
                                    self.UIState.greetingUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.greetingUIState.color = brandAccount.valor12C ?? "#0082C7"
                                self.UIState.greetingUIState.size = brandAccount.valor13C ?? "14"
                                //MARK: - UserPointConfig
                                self.UIState.userPointUIState.background = brandAccount.valor21C ?? "#004A99"
                                self.UIState.userPointUIState.color = brandAccount.valor22C ?? "#FFFFFF"
                                self.UIState.userPointUIState.size = brandAccount.valor23C ?? "15"
                                //MARK: - NotificationConfig
                                self.UIState.notificationUIState.URLWithoutNotification = brandAccount.valor31C ?? "haveNotification"
                                self.UIState.notificationUIState.URLWithNotification = brandAccount.valor32C ?? ""
                                //MARK: - BannersConfig
                                self.UIState.bannersUIState.URLBanner1 = brandAccount.atributo41C ?? ""
                                self.UIState.bannersUIState.URLBanner2 = brandAccount.atributo42C ?? ""
                                self.UIState.bannersUIState.URLBanner3 = brandAccount.atributo43C ?? ""
                                self.UIState.bannersUIState.URLBanner4 = brandAccount.atributo44C ?? ""
                                self.UIState.bannersUIState.URLBanner5 = brandAccount.atributo45C ?? ""
                                self.UIState.bannersUIState.URLBanner6 = brandAccount.atributo46C ?? ""
                                self.UIState.bannersUIState.URLValor1 = brandAccount.valor41C ?? ""
                                self.UIState.bannersUIState.URLValor2 = brandAccount.valor42C ?? ""
                                self.UIState.bannersUIState.URLValor3 = brandAccount.valor43C ?? ""
                                self.UIState.bannersUIState.URLValor4 = brandAccount.valor44C ?? ""
                                self.UIState.bannersUIState.URLValor5 = brandAccount.valor45C ?? ""
                                self.UIState.bannersUIState.URLValor6 = brandAccount.valor46C ?? ""
                                //MARK: - LabelClinicConfig
                                self.UIState.firstLabelUIState.text = brandAccount.valor51C ?? "Clinicas"
                                if brandAccount.valor52C == "firasans_regular" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor52C == "firasans_bold" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor52C == "firasans_italic" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.firstLabelUIState.color = brandAccount.valor53C ?? "#004A99"
                                self.UIState.firstLabelUIState.size = brandAccount.valor54C ?? "18"
                                //MARK: - LabelSeeAllConfig
                                self.UIState.labelSeeAllUIState.text = brandAccount.valor81C ?? ""
                                if brandAccount.valor82C == "firasans_regular" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor82C == "firasans_bold" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor82C == "firasans_italic" {
                                    self.UIState.labelSeeAllUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelSeeAllUIState.color = brandAccount.valor83C ?? "#0082C7"
                                self.UIState.labelSeeAllUIState.size = brandAccount.valor84C ?? "15"
                                //MARK: - LabelTaskConfig
                                self.UIState.labelTaskUIState.text = brandAccount.valor91C ?? ""
                                if brandAccount.valor92C == "firasans_regular" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor92C == "firasans_bold" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor92C == "firasans_italic" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelTaskUIState.color = brandAccount.valor93C ?? "#004A99"
                                self.UIState.labelTaskUIState.size = brandAccount.valor94C ?? "18"
                                
                            }

                        }
                        //MARK: - Tipe Sub Home 2
                        if tipeSubHome.last == 2 {
                            if brandAccount.Name == (UIState.customSubHomeName.last ?? "SubHome2"){
                                //MARK: - GreetingsConfig
                                if brandAccount.valor11C == "firasans_regular" {
                                    self.UIState.greetingUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor11C == "firasans_bold" {
                                    self.UIState.greetingUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor11C == "firasans_italic" {
                                    self.UIState.greetingUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.greetingUIState.color = brandAccount.valor12C ?? "#0082C7"
                                self.UIState.greetingUIState.size = brandAccount.valor13C ?? "14"
                                //MARK: - UserPointConfig
                                self.UIState.userPointUIState.background = brandAccount.valor21C ?? "#004A99"
                                self.UIState.userPointUIState.color = brandAccount.valor22C ?? "#FFFFFF"
                                self.UIState.userPointUIState.size = brandAccount.valor23C ?? "15"
                                //MARK: - NotificationConfig
                                self.UIState.notificationUIState.URLWithoutNotification = brandAccount.valor31C ?? "haveNotification"
                                self.UIState.notificationUIState.URLWithNotification = brandAccount.valor32C ?? ""
                                //MARK: - BannersConfig
                                self.UIState.bannersUIState.URLBanner1 = brandAccount.atributo41C ?? ""
                                self.UIState.bannersUIState.URLBanner2 = brandAccount.atributo42C ?? ""
                                self.UIState.bannersUIState.URLBanner3 = brandAccount.atributo43C ?? ""
                                self.UIState.bannersUIState.URLBanner4 = brandAccount.atributo44C ?? ""
                                self.UIState.bannersUIState.URLBanner5 = brandAccount.atributo45C ?? ""
                                self.UIState.bannersUIState.URLBanner6 = brandAccount.atributo46C ?? ""
                                self.UIState.bannersUIState.URLValor1 = brandAccount.valor41C ?? ""
                                self.UIState.bannersUIState.URLValor2 = brandAccount.valor42C ?? ""
                                self.UIState.bannersUIState.URLValor3 = brandAccount.valor43C ?? ""
                                self.UIState.bannersUIState.URLValor4 = brandAccount.valor44C ?? ""
                                self.UIState.bannersUIState.URLValor5 = brandAccount.valor45C ?? ""
                                self.UIState.bannersUIState.URLValor6 = brandAccount.valor46C ?? ""
                                //MARK: - FirstLabelConfig
                                self.UIState.firstLabelUIState.text = brandAccount.valor51C ?? ""
                                if brandAccount.valor52C == "firasans_regular" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor52C == "firasans_bold" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor52C == "firasans_italic" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.firstLabelUIState.color = brandAccount.valor53C ?? "#004A99"
                                self.UIState.firstLabelUIState.size = brandAccount.valor54C ?? "18"
                                //MARK: - SecondLabelConfig
                                self.UIState.secondLabelUIState.text = brandAccount.valor61C ?? ""
                                if brandAccount.valor62C == "firasans_regular" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor62C == "firasans_bold" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor62C == "firasans_italic" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.secondLabelUIState.color = brandAccount.valor63C ?? "#004A99"
                                self.UIState.secondLabelUIState.size = brandAccount.valor64C ?? "18"
                                //MARK: - LabelTaskConfig
                                self.UIState.labelTaskUIState.text = brandAccount.valor71C ?? ""
                                if brandAccount.valor72C == "firasans_regular" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor72C == "firasans_bold" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor72C == "firasans_italic" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelTaskUIState.color = brandAccount.valor73C ?? "#004A99"
                                self.UIState.labelTaskUIState.size = brandAccount.valor74C ?? "18"
                            }

                        }
                        //MARK: - Tipe Sub Home 3
                        if tipeSubHome.last == 3 {
                            if brandAccount.Name == (UIState.customSubHomeName.last ?? "SubHome3"){
                                //MARK: - GreetingsConfig
                                if brandAccount.valor11C == "firasans_regular" {
                                    self.UIState.greetingUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor11C == "firasans_bold" {
                                    self.UIState.greetingUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor11C == "firasans_italic" {
                                    self.UIState.greetingUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.greetingUIState.color = brandAccount.valor12C ?? "#0082C7"
                                self.UIState.greetingUIState.size = brandAccount.valor13C ?? "14"
                                //MARK: - UserPointConfig
                                self.UIState.userPointUIState.background = brandAccount.valor21C ?? "#004A99"
                                self.UIState.userPointUIState.color = brandAccount.valor22C ?? "#FFFFFF"
                                self.UIState.userPointUIState.size = brandAccount.valor23C ?? "15"
                                //MARK: - NotificationConfig
                                self.UIState.notificationUIState.URLWithoutNotification = brandAccount.valor31C ?? "haveNotification"
                                self.UIState.notificationUIState.URLWithNotification = brandAccount.valor32C ?? ""
                                //MARK: - BannersConfig
                                self.UIState.bannersUIState.URLBanner1 = brandAccount.atributo41C ?? ""
                                self.UIState.bannersUIState.URLBanner2 = brandAccount.atributo42C ?? ""
                                self.UIState.bannersUIState.URLBanner3 = brandAccount.atributo43C ?? ""
                                self.UIState.bannersUIState.URLBanner4 = brandAccount.atributo44C ?? ""
                                self.UIState.bannersUIState.URLBanner5 = brandAccount.atributo45C ?? ""
                                self.UIState.bannersUIState.URLBanner6 = brandAccount.atributo46C ?? ""
                                self.UIState.bannersUIState.URLValor1 = brandAccount.valor41C ?? ""
                                self.UIState.bannersUIState.URLValor2 = brandAccount.valor42C ?? ""
                                self.UIState.bannersUIState.URLValor3 = brandAccount.valor43C ?? ""
                                self.UIState.bannersUIState.URLValor4 = brandAccount.valor44C ?? ""
                                self.UIState.bannersUIState.URLValor5 = brandAccount.valor45C ?? ""
                                self.UIState.bannersUIState.URLValor6 = brandAccount.valor46C ?? ""
                                //MARK: - SecondBannersConfig
                                self.UIState.SecondBannersUIState.URLBanner1 = brandAccount.atributo51C ?? ""
                                self.UIState.SecondBannersUIState.URLBanner2 = brandAccount.atributo52C ?? ""
                                self.UIState.SecondBannersUIState.URLBanner3 = brandAccount.atributo53C ?? ""
                                self.UIState.SecondBannersUIState.URLBanner4 = brandAccount.atributo54C ?? ""
                                self.UIState.SecondBannersUIState.URLBanner5 = brandAccount.atributo55C ?? ""
                                self.UIState.SecondBannersUIState.URLBanner6 = brandAccount.atributo56C ?? ""
                                self.UIState.SecondBannersUIState.URLValor1 = brandAccount.valor51C ?? ""
                                self.UIState.SecondBannersUIState.URLValor2 = brandAccount.valor52C ?? ""
                                self.UIState.SecondBannersUIState.URLValor3 = brandAccount.valor53C ?? ""
                                self.UIState.SecondBannersUIState.URLValor4 = brandAccount.valor54C ?? ""
                                self.UIState.SecondBannersUIState.URLValor5 = brandAccount.valor55C ?? ""
                                self.UIState.SecondBannersUIState.URLValor6 = brandAccount.valor56C ?? ""
                                //MARK: - FirstLabelConfig
                                self.UIState.firstLabelUIState.text = brandAccount.valor61C ?? ""
                                if brandAccount.valor62C == "firasans_regular" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor62C == "firasans_bold" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor62C == "firasans_italic" {
                                    self.UIState.firstLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.firstLabelUIState.color = brandAccount.valor63C ?? "#004A99"
                                self.UIState.firstLabelUIState.size = brandAccount.valor64C ?? "18"
                                //MARK: - SecondLabelConfig
                                self.UIState.secondLabelUIState.text = brandAccount.valor71C ?? ""
                                if brandAccount.valor72C == "firasans_regular" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor72C == "firasans_bold" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor72C == "firasans_italic" {
                                    self.UIState.secondLabelUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.secondLabelUIState.color = brandAccount.valor73C ?? "#004A99"
                                self.UIState.secondLabelUIState.size = brandAccount.valor74C ?? "18"
                                //MARK: - LabelTaskConfig
                                self.UIState.labelTaskUIState.text = brandAccount.valor81C ?? ""
                                if brandAccount.valor82C == "firasans_regular" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Regular"
                                }
                                if brandAccount.valor82C == "firasans_bold" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Bold"
                                }
                                if brandAccount.valor82C == "firasans_italic" {
                                    self.UIState.labelTaskUIState.font = "FiraSans-Italic"
                                }
                                self.UIState.labelTaskUIState.color = brandAccount.valor83C ?? "#004A99"
                                self.UIState.labelTaskUIState.size = brandAccount.valor84C ?? "18"
                            }

                        }
                        if brandAccount.Name == "PopUpProgramas"{
                            self.UIState.customPopupLoadingProgram.popupMessage = brandAccount.valor11C ?? ""
                            if let valor = brandAccount.valor12C?.components(separatedBy: ";"), valor.count >= 3{
                                self.UIState.customPopupLoadingProgram.popupAtr.colorText = valor[2]
                                self.UIState.customPopupLoadingProgram.popupAtr.sizeText = valor[1]
                                if valor[0] == "firasans_regular" {
                                    self.UIState.customPopupLoadingProgram.popupAtr.font = "FiraSans-Regular"
                                }
                                if valor[0] == "firasans_bold" {
                                    self.UIState.customPopupLoadingProgram.popupAtr.font = "FiraSans-Bold"
                                }
                                if valor[0] == "firasans_italic" {
                                    self.UIState.customPopupLoadingProgram.popupAtr.font = "FiraSans-Italic"
                                }
                            }
                            self.UIState.customPopupLoadingProgram.popupAtr.alignment = brandAccount.valor13C?.lowercased() ?? ""
                            self.UIState.customPopupLoadingProgram.loadingColor = brandAccount.valor14C ?? ""
                            
                            self.UIState.customPopupFailureProgram.popupMessage = brandAccount.valor21C ?? ""
                            if let valor = brandAccount.valor22C?.components(separatedBy: ";"), valor.count >= 3{
                                self.UIState.customPopupFailureProgram.popupAtr.colorText = valor[2]
                                self.UIState.customPopupFailureProgram.popupAtr.sizeText = valor[1]
                                if valor[0] == "firasans_regular" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Regular"
                                }
                                if valor[0] == "firasans_bold" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Bold"
                                }
                                if valor[0] == "firasans_italic" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Italic"
                                }
                            }
                            self.UIState.customPopupFailureProgram.popupAtr.alignment = brandAccount.valor23C?.lowercased() ?? ""
                            
                            if let valor = brandAccount.valor24C?.components(separatedBy: ";"), valor.count >= 3{
                                self.UIState.customPopupFailureProgram.btnPopup.textBtn = valor[0]
                                self.UIState.customPopupFailureProgram.btnPopup.colorTextBtn = valor[1]
                                if valor[2] == "firasans_regular" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Regular"
                                }
                                if valor[2] == "firasans_bold" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Bold"
                                }
                                if valor[2] == "firasans_italic" {
                                    self.UIState.customPopupFailureProgram.popupAtr.font = "FiraSans-Italic"
                                }
                            }
                        }
                        
                    }
                }
    }
}
