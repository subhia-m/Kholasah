//
//  intredac.swift
//  Kholasah
//
//  Created by jenan on 15/05/1448 AH.

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background color matching the design theme (warm cream)
            Color(#colorLiteral(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0))
                .ignoresSafeArea()
            
            VStack {
                // Top Skip Button (Hidden on the last page)
                HStack {
                    Spacer()
                    if currentPage < 4 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = 4
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    } else {
                        Text("").padding(.horizontal, 24).padding(.top, 10)
                    }
                }
                
                // Paging TabView for the 5 screens
                TabView(selection: $currentPage) {
                    PageView1().tag(0)
                    PageView2().tag(1)
                    PageView3().tag(2)
                    PageView4().tag(3)
                    PageView5().tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom Controls: Page Indicator Dots & Next Arrow Button
                HStack {
                    // Custom Page Dots
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)) : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 16 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    // Next Button (Hidden on page 5 since page 5 has "Get Started")
                    if currentPage < 4 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

// Page 1: Splash / Cover
struct PageView1: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 4) {
                    Image(systemName: "circle.grid.cross.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                    Text("خلاصة")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                }
            }
            
            Text("Kholasah")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
            
            Text("Turn your materials\ninto progress.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Page 2: Welcome to Kholasah
struct PageView2: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(#colorLiteral(red: 0.93, green: 0.91, blue: 0.86, alpha: 1.0)))
                    .frame(height: 280)
                
                VStack {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.4, blue: 0.2, alpha: 1.0)))
                    Text("Upload. Plan. Learn. Progress.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Welcome to\nKholasah")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                
                Text("Your personal study companion that turns your materials into a clear plan.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
}

// MARK: - Page 3: Upload your study materials
struct PageView3: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(#colorLiteral(red: 0.93, green: 0.91, blue: 0.86, alpha: 1.0)))
                    .frame(height: 280)
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        FileBadge(title: "PDF", color: .red)
                        FileBadge(title: "DOC", color: .blue)
                        FileBadge(title: "PPT", color: .orange)
                    }
                    
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                        Text("Upload your files")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                        Text("PDF, PPT, DOC, or images")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Upload your\nstudy materials")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                
                Text("Upload your slides, notes, or files and let AI create a personalized study plan.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
}

struct FileBadge: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(8)
    }
}

// MARK: - Page 4: Get a clear study plan
struct PageView4: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(#colorLiteral(red: 0.93, green: 0.91, blue: 0.86, alpha: 1.0)))
                    .frame(height: 280)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Your Plan")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                    
                    PlanRow(icon: "book", title: "Review notes", time: "25 min")
                    PlanRow(icon: "pencil", title: "Practice quiz", time: "15 min")
                    PlanRow(icon: "doc.text", title: "Read chapter 3", time: "20 min")
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Get a clear\nstudy plan")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                
                Text("Kholasah breaks your materials into topics, sets a schedule, and helps you stay consistent with reminders.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
}

struct PlanRow: View {
    let icon: String
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                .frame(width: 20)
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
            Text(time)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Page 5: Stay motivated every day
struct PageView5: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(#colorLiteral(red: 0.93, green: 0.91, blue: 0.86, alpha: 1.0)))
                    .frame(height: 280)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "bell", title: "Smart reminders")
                    FeatureRow(icon: "questionmark.circle", title: "Quizzes from your materials")
                    FeatureRow(icon: "chart.bar", title: "Track your progress")
                    FeatureRow(icon: "heart", title: "Build a lasting learning habit")
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Stay motivated\nevery day")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                
                Text("Daily notifications, small quizzes, and progress tracking to help you build a consistent habit.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                
                // Get Started Action Button
                Button(action: {
                    // Add your action to navigate to main app here
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(#colorLiteral(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)))
                .frame(width: 24)
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
