//
//  ProfileExporter.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation

/// Exports user profile data as JSON and markdown bundle
enum ProfileExporter {
    
    /// Export complete profile data to Documents/EverForm/export/
    static func exportProfile(
        profile: UserProfile?,
        targets: UserTargets?,
        advanced: ProfileAdvanced?,
        notes: String?,
        attachments: [LabAttachment]
    ) throws -> URL {
        let exportDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("EverForm/export", isDirectory: true)
        
        try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
        
        let timestamp = DateFormatter.exportTimestamp.string(from: Date())
        let exportBundle = exportDir.appendingPathComponent("profile_export_\(timestamp)", isDirectory: true)
        
        try FileManager.default.createDirectory(at: exportBundle, withIntermediateDirectories: true)
        
        // Export JSON data
        let jsonData = try createJSONExport(
            profile: profile,
            targets: targets,
            advanced: advanced,
            notes: notes,
            attachments: attachments
        )
        
        let jsonURL = exportBundle.appendingPathComponent("profile_data.json")
        try jsonData.write(to: jsonURL)
        
        // Export markdown summary
        let markdown = createMarkdownSummary(
            profile: profile,
            targets: targets,
            advanced: advanced,
            notes: notes
        )
        
        let markdownURL = exportBundle.appendingPathComponent("profile_summary.md")
        try markdown.data(using: .utf8)?.write(to: markdownURL)
        
        // Export notes separately if they exist
        if let notes = notes, !notes.isEmpty {
            let notesURL = exportBundle.appendingPathComponent("profile_notes.md")
            try notes.data(using: .utf8)?.write(to: notesURL)
        }
        
        // Create attachment list
        if !attachments.isEmpty {
            let attachmentList = attachments.map { attachment in
                "- \(attachment.filename) (added: \(attachment.addedAt.formatted()))"
            }.joined(separator: "\n")
            
            let attachmentListURL = exportBundle.appendingPathComponent("attachments.txt")
            try attachmentList.data(using: .utf8)?.write(to: attachmentListURL)
        }
        
        // Create README
        let readme = createReadme()
        let readmeURL = exportBundle.appendingPathComponent("README.txt")
        try readme.data(using: .utf8)?.write(to: readmeURL)
        
        print("📦 ProfileExporter: Exported profile to \(exportBundle.path)")
        return exportBundle
    }
    
    private static func createJSONExport(
        profile: UserProfile?,
        targets: UserTargets?,
        advanced: ProfileAdvanced?,
        notes: String?,
        attachments: [LabAttachment]
    ) throws -> Data {
        let exportData: [String: Any] = [
            "profile": profile as Any,
            "targets": targets as Any,
            "advanced": advanced as Any,
            "notes": notes as Any,
            "attachments": attachments.map { attachment in
                [
                    "filename": attachment.filename,
                    "addedAt": attachment.addedAt,
                    "userNotes": attachment.userNotes as Any
                ]
            },
            "exportedAt": Date(),
            "version": "1.0"
        ]
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    private static func createMarkdownSummary(
        profile: UserProfile?,
        targets: UserTargets?,
        advanced: ProfileAdvanced?,
        notes: String?
    ) -> String {
        var markdown = "# EverForm Profile Summary\n\n"
        markdown += "Exported: \(Date().formatted())\n\n"
        
        if let profile = profile {
            let age = Calendar.current.dateComponents([.year], from: profile.birthdate, to: Date()).year ?? 0
            
            markdown += "## Basic Profile\n\n"
            markdown += "- **Name**: \(profile.name)\n"
            markdown += "- **Age**: \(age) years\n"
            markdown += "- **Sex**: \(profile.sex.rawValue)\n"
            markdown += "- **Height**: \(Int(profile.heightCm)) cm\n"
            markdown += "- **Weight**: \(Int(profile.weightKg)) kg\n"
            markdown += "- **Goal**: \(profile.goal.rawValue)\n"
            markdown += "- **Diet**: \(profile.diet.rawValue)\n"
            markdown += "- **Activity**: \(profile.activity.rawValue)\n"
            
            if !profile.allergies.isEmpty {
                markdown += "- **Allergies**: \(profile.allergies.joined(separator: ", "))\n"
            }
            
            if !profile.injuries.isEmpty {
                markdown += "- **Injuries**: \(profile.injuries.joined(separator: ", "))\n"
            }
            
            markdown += "\n"
        }
        
        if let targets = targets {
            markdown += "## Nutrition Targets\n\n"
            markdown += "- **Calories**: \(targets.targetCalories) kcal\n"
            markdown += "- **Protein**: \(targets.proteinG) g\n"
            markdown += "- **Carbs**: \(targets.carbsG) g\n"
            markdown += "- **Fat**: \(targets.fatG) g\n"
            markdown += "- **Hydration**: \(targets.hydrationMl) ml\n"
            markdown += "- **Sleep**: \(String(format: "%.1f", targets.sleepHours)) hours\n\n"
        }
        
        if let advanced = advanced {
            markdown += "## Advanced Profile\n\n"
            
            if advanced.bloodType != .unknown {
                markdown += "- **Blood Type**: \(advanced.bloodType.rawValue)\n"
            }
            
            if advanced.chronotype != .unknown {
                markdown += "- **Chronotype**: \(advanced.chronotype.rawValue)\n"
            }
            
            if !advanced.knownConditions.isEmpty {
                markdown += "- **Health Conditions**: \(advanced.knownConditions.joined(separator: ", "))\n"
            }
            
            if !advanced.supplements.isEmpty {
                markdown += "- **Supplements**: \(advanced.supplements.joined(separator: ", "))\n"
            }
            
            if !advanced.foodDislikes.isEmpty {
                markdown += "- **Food Dislikes**: \(advanced.foodDislikes.joined(separator: ", "))\n"
            }
            
            markdown += "\n"
        }
        
        if let notes = notes, !notes.isEmpty {
            markdown += "## Personal Notes\n\n"
            markdown += notes
            markdown += "\n\n"
        }
        
        return markdown
    }
    
    private static func createReadme() -> String {
        return """
        # EverForm Profile Export
        
        This folder contains your complete EverForm profile data:
        
        - `profile_data.json` - Complete profile data in JSON format
        - `profile_summary.md` - Human-readable profile summary
        - `profile_notes.md` - Your personal notes (if any)
        - `attachments.txt` - List of uploaded documents (if any)
        
        ## Data Privacy
        
        This export contains your personal health and fitness data. Please handle with care and store securely.
        
        ## Import
        
        This data can potentially be imported back into EverForm or used with other health and fitness applications.
        
        Generated by EverForm v1.0
        """
    }
}

private extension DateFormatter {
    static let exportTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}
