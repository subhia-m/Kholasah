import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import UIKit

struct CourseView: View {

    // MARK: - Form Data

    @State private var courseName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var motivationType = "Choose a type"
    @State private var goals = ""
    @State private var additionalGoals = ""

    // Upload states
    @State private var showUploadOptions = false
    @State private var showFileImporter = false
    @State private var showPhotoPicker = false
    @State private var selectedFiles: [URL] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""


    private let motivationTypes = [
        "bbbbb",
        "aaaaa",
        "ccccc",
        "ddddd",
        "Other"
    ]

    // MARK: - Colors

    private let backgroundColor = Color(
        red: 0.96, green: 0.94, blue: 0.92
    )

    private let darkBrown = Color(
        red: 0.31, green: 0.04, blue: 0.01
    )

    private let titleBrown = Color(
        red: 0.42, green: 0.10, blue: 0.06
    )

    private let labelOrange = Color(
        red: 0.73, green: 0.36, blue: 0.16
    )

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            GeometryReader { geometry in
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .offset(x: -150, y: 102)
                    .opacity(0.2)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                
                // MARK: Header
                
                Text("Add Course")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(titleBrown)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // MARK: Form
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // Course Name
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Course Name:")
                            
                            TextField(
                                "Enter course name",
                                text: $courseName
                            )
                            .padding(.horizontal, 18)
                            .frame(height: 70)
                            .background(fieldBackground)
                            .textInputAutocapitalization(.words)
                        }
                        
                        // Start Date and End Date
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("Start Date:")
                                
                                DatePicker(
                                    "Start Date",
                                    selection: $startDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("End Date:")
                                
                                DatePicker(
                                    "End Date",
                                    selection: $endDate,
                                    in: startDate...,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                            }
                        }
                        
                        // Motivation Type
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Motivation Type:")
                            
                            Picker(
                                "Motivation Type",
                                selection: $motivationType
                            ) {
                                Text("Choose a type")
                                    .tag("Choose a type")
                                
                                ForEach(
                                    motivationTypes,
                                    id: \.self
                                ) { type in
                                    Text(type)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(darkBrown)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 70,
                                alignment: .leading
                            )
                            .padding(.horizontal, 18)
                            .background(fieldBackground)
                        }
                        
                        // Goals
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Goals:")
                            
                            TextField(
                                "What do you want to achieve?",
                                text: $goals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // Tasks
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Tasks:")
                            
                            TextField(
                                "Add your tasks",
                                text: $additionalGoals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // MARK: Course Materials
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Course Materials:")
                            
                            Button {
                                showUploadOptions = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 21))
                                        .foregroundStyle(darkBrown)
                                    
                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {
                                        Text("Upload materials")
                                            .font(.system(size: 15))
                                            .foregroundStyle(darkBrown)
                                        
                                        Text(
                                            "\(selectedFiles.count + selectedPhotos.count) item(s) selected"
                                        )
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 62
                                )
                                .background(fieldBackground)
                            }
                            .buttonStyle(.plain)
                            .confirmationDialog(
                                "Upload Course Materials",
                                isPresented: $showUploadOptions,
                                titleVisibility: .visible
                            ) {
                               
                                Button("Choose Files") {
                                    showFileImporter = true
                                }
                                
                                Button("Cancel", role: .cancel) { }
                            }
                            
                        }
                        
                        
                        // MARK: Done Button
                        Button {
                            if courseName.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty {
                                alertMessage = "Please enter a course name before continuing."
                                showAlert = true
                            } else {
                                print("Course: \(courseName)")
                                print("Start: \(startDate)")
                                print("End: \(endDate)")
                                print("Motivation: \(motivationType)")
                                print("Goals: \(goals)")
                                print("Tasks: \(additionalGoals)")
                                print("Files: \(selectedFiles)")
                                print("Photos selected: \(selectedPhotos.count)")
                            }
                        } label: {
                            Text("Generate study plan")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(darkBrown)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 30)
                                )
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        // MARK: File Importer
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                .pdf,
                .presentation,
                .image,
                .plainText
            ] + [
                "doc", "docx", "ppt", "pptx"
            ].compactMap {
                UTType(filenameExtension: $0)
            },
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                selectedFiles = urls
            case .failure(let error):
                print("File selection failed: \(error)")
            }
        }
        // MARK: Alert
        .alert(
            "Course",
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Reusable Components

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.white.opacity(0.92))
            .shadow(
                color: Color.brown.opacity(0.13),
                radius: 10,
                x: 0,
                y: 6
            )
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(titleBrown)
            .padding(.leading, 10)
    }
}

#Preview {
    CourseView()
}
