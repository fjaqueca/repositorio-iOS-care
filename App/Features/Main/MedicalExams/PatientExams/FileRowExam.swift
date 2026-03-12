//
//  FileRowExam.swift
//  CareAssistance
//
//  Created by The App Master on 11/07/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct FileRowExam: View {
    @Binding var fileExam: FileExam
    @Binding var isExamPublish: Bool
    @Binding var UIState: ExamUIState
    let onSelect: (UUID) -> Void
    let onDownload: () -> Void

    var body: some View {
        VStack {
            Button {
                if fileExam.imgData.isEmpty && fileExam.urlImg.isEmpty && !isExamPublish {
                    onSelect(fileExam.id)
                } else if !fileExam.urlImg.isEmpty {
                    onDownload()
                }
            } label: {
                if fileExam.imgData.isEmpty && fileExam.urlImg.isEmpty {
                    Image("camera")
                        .renderingMode(.template)
                        .tint(Color(hex: UIState.examDetail.sendedExam.color))
                        .padding(.margin)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundColor(Color(hex: UIState.examDetail.sendedExam.color))
                        )
                } else {
                    VStack {
                        Image("imageSelected")
                            .renderingMode(.template)
                            .tint(Color(hex: UIState.examDetail.sendedExam.color))
                            .padding(.margin)
                            .overlay(
                                ZStack {
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 1))
                                        .foregroundColor(Color(hex: UIState.examDetail.sendedExam.color))

                                    VStack {
                                        HStack {
                                            Spacer()
                                            if !isExamPublish {
                                                if let url = URL(string: UIState.examDetail.svgDeletArchive), !UIState.examDetail.svgDeletArchive.isEmpty {
                                                    WebImage(url: url) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(alignment: .topTrailing)
                                                            .frame(height: 15)
                                                            .onTapGesture {
                                                                fileExam.imgData = ""
                                                                fileExam.urlImg = ""
                                                                fileExam.archiveExtension = ""
                                                            }
                                                    } placeholder: {
                                                        EmptyView()
                                                    }
                                                } else {
                                                    Image("close")
                                                        .frame(alignment: .topTrailing)
                                                        .onTapGesture {
                                                            fileExam.imgData = ""
                                                            fileExam.urlImg = ""
                                                            fileExam.archiveExtension = ""
                                                        }
                                                }
                                            }
                                        }
                                        Spacer()
                                        Text(fileExam.archiveExtension.isEmpty ? "arch" : "arch.\(fileExam.archiveExtension)")
                                            .font(.appCaptionLarge)
                                            .foregroundColor(Color(hex: UIState.examDetail.sendedExam.color))
                                    }
                                }
                            )
                    }
                }
            }
            .padding(.bottom)
        }
    }
}
