//
//  CollaborationHubView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

struct CollaborationHubView: View {
    @State private var contacts: [StudyContact] = []
    @State private var showAddContact = false
    @State private var searchText = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("🤝 Study Contacts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Connect with teachers and fellow students")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Stats and Add Button
                HStack(spacing: 16) {
                    VStack {
                        Text("\(contacts.filter { $0.type == .teacher }.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                        Text("Teachers")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .neumorphic()
                    
                    VStack {
                        Text("\(contacts.filter { $0.type == .student }.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryYellow)
                        Text("Students")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .neumorphic()
                    
                    Button(action: {
                        showAddContact = true
                    }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("Add")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .neumorphic()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    TextField("Search contacts...", text: $searchText)
                        .foregroundColor(.textPrimary)
                }
                .padding()
                .neumorphic()
                .padding(.horizontal, 20)
                
                // Contacts List
                if filteredContacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.textSecondary)
                        
                        Text("No Contacts Yet")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text("Add teachers and students to build your study network")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add First Contact") {
                            showAddContact = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(40)
                    .neumorphic()
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredContacts, id: \.id) { contact in
                            ContactCard(contact: contact) {
                                removeContact(contact)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 20)
        }
        .appBackground()
        .sheet(isPresented: $showAddContact) {
            AddContactSheet { newContact in
                contacts.append(newContact)
                saveContacts()
            }
        }
        .onAppear {
            loadContacts()
            print("🤝 CommunityView: Study Contacts - onAppear called")
        }
    }
    
    private var filteredContacts: [StudyContact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.languages.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ||
                contact.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadContacts() {
        // Add sample contacts
        contacts = [
            StudyContact(
                name: "Maria Rodriguez",
                type: .teacher,
                languages: ["Spanish", "English"],
                contact: "maria@email.com",
                notes: "Professional Spanish teacher with 10 years experience",
                rating: 5.0
            ),
            StudyContact(
                name: "Jean Dupont",
                type: .teacher,
                languages: ["French"],
                contact: "@jean_teacher",
                notes: "Native French speaker, specialized in conversation practice",
                rating: 4.8
            ),
            StudyContact(
                name: "Alex Johnson",
                type: .student,
                languages: ["German", "Italian"],
                contact: "alex@email.com",
                notes: "Study partner for German conversation practice",
                rating: 4.5
            )
        ]
    }
    
    private func saveContacts() {
        // Simple save - in real app would use Core Data or similar
        print("Contacts saved: \(contacts.count)")
    }
    
    private func removeContact(_ contact: StudyContact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }
}

struct ContactCard: View {
    let contact: StudyContact
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar and Type
            VStack {
                ZStack {
                    Circle()
                        .fill(contact.type == .teacher ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: contact.type == .teacher ? "graduationcap.fill" : "person.fill")
                        .font(.title2)
                        .foregroundColor(contact.type == .teacher ? .green : .blue)
                }
                
                Text(contact.type.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // Rating Stars
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(contact.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.primaryYellow)
                        }
                    }
                }
                
                // Languages
                HStack {
                    ForEach(contact.languages.prefix(3), id: \.self) { language in
                        Text(language)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryYellow.opacity(0.2))
                            .foregroundColor(.primaryYellow)
                            .cornerRadius(4)
                    }
                    
                    if contact.languages.count > 3 {
                        Text("+\(contact.languages.count - 3)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Contact Info
                Text(contact.contact)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                // Notes
                if !contact.notes.isEmpty {
                    Text(contact.notes)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
            }
            
            // Actions
            VStack(spacing: 8) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .neumorphic()
        .alert("Delete Contact", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \(contact.name) from your contacts?")
        }
    }
}

struct AddContactSheet: View {
    let onAdd: (StudyContact) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var type: StudyContact.ContactType = .student
    @State private var contact = ""
    @State private var notes = ""
    @State private var selectedLanguages: [String] = []
    @State private var rating: Int = 5
    
    private let availableLanguages = ["German", "French", "Italian", "Polish", "Turkish", "Japanese", "English", "Spanish"]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Enter full name", text: $name)
                            .padding()
                            .neumorphic()
                    }
                    
                    // Type Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Picker("Contact Type", selection: $type) {
                            Text("Teacher").tag(StudyContact.ContactType.teacher)
                            Text("Student").tag(StudyContact.ContactType.student)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact Info")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Email, phone, or username", text: $contact)
                            .padding()
                            .neumorphic()
                    }
                    
                    // Languages
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Languages")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(availableLanguages, id: \.self) { language in
                                Button(action: {
                                    if selectedLanguages.contains(language) {
                                        selectedLanguages.removeAll { $0 == language }
                                    } else {
                                        selectedLanguages.append(language)
                                    }
                                }) {
                                    Text(language)
                                        .font(.subheadline)
                                        .foregroundColor(selectedLanguages.contains(language) ? .black : .textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedLanguages.contains(language) ? Color.primaryYellow : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.primaryYellow, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    rating = index
                                }) {
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(index <= rating ? .primaryYellow : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                            
                            Text("\(rating) star\(rating == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Add notes about this contact...", text: $notes)
                            .lineLimit(3)
                            .padding()
                            .neumorphic()
                    }
                    
                    // Add Button
                    Button(action: {
                        let newContact = StudyContact(
                            name: name,
                            type: type,
                            languages: selectedLanguages,
                            contact: contact,
                            notes: notes,
                            rating: Double(rating)
                        )
                        onAdd(newContact)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Contact")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(name.isEmpty || contact.isEmpty || selectedLanguages.isEmpty)
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Study Contact Model
struct StudyContact: Identifiable {
    let id = UUID()
    let name: String
    let type: ContactType
    let languages: [String]
    let contact: String
    let notes: String
    let rating: Double
    
    enum ContactType: String, CaseIterable {
        case teacher = "teacher"
        case student = "student"
    }
}

#Preview {
    CollaborationHubView()
}