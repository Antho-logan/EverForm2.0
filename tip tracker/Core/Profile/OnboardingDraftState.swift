import Foundation

enum GoalFocus: String, Codable, CaseIterable, Hashable {
    case loseFat = "Lose fat"
    case buildMuscle = "Build muscle"
    case feelBetter = "Feel better"
    case improveHealth = "Improve health"
    case increaseEnergy = "Increase energy"
    case betterSleep = "Better sleep"
}

/// Single source of truth for onboarding draft data used across the new flow.
struct OnboardingDraftState: Codable {
    var name = ""
    var birthdate = Date()
    var heightCm: Double = 170
    var weightKg: Double? = 70
    var weightUnknown = false
    var sex: UserProfile.Sex = .male
    var goal: UserProfile.Goal = .maintainWeight
    var activity: UserProfile.Activity = .moderate
    var diet: UserProfile.Diet = .balanced
    var allergies: [String] = []
    var goals: [String] = []
    var goalFocus: Set<GoalFocus> = []
    var notes = ""

    init() {}

    private enum CodingKeys: String, CodingKey {
        case name, birthdate, heightCm, weightKg, weightUnknown, sex, goal, activity, diet, allergies, goals, goalFocus, notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        birthdate = try container.decodeIfPresent(Date.self, forKey: .birthdate) ?? Date()
        heightCm = try container.decodeIfPresent(Double.self, forKey: .heightCm) ?? 170
        weightKg = try container.decodeIfPresent(Double.self, forKey: .weightKg)
        weightUnknown = try container.decodeIfPresent(Bool.self, forKey: .weightUnknown) ?? false

        let sexRaw = try container.decodeIfPresent(String.self, forKey: .sex)
        sex = UserProfile.Sex(rawValue: sexRaw ?? "") ?? .male

        let goalRaw = try container.decodeIfPresent(String.self, forKey: .goal)
        goal = UserProfile.Goal(rawValue: goalRaw ?? "") ?? .maintainWeight

        let activityRaw = try container.decodeIfPresent(String.self, forKey: .activity)
        activity = UserProfile.Activity(rawValue: activityRaw ?? "") ?? .moderate

        let dietRaw = try container.decodeIfPresent(String.self, forKey: .diet)
        diet = UserProfile.Diet(rawValue: dietRaw ?? "") ?? .balanced

        allergies = try container.decodeIfPresent([String].self, forKey: .allergies) ?? []
        goals = try container.decodeIfPresent([String].self, forKey: .goals) ?? []
        let goalFocusArray = try container.decodeIfPresent([GoalFocus].self, forKey: .goalFocus) ?? []
        goalFocus = Set(goalFocusArray)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(birthdate, forKey: .birthdate)
        try container.encode(heightCm, forKey: .heightCm)
        try container.encode(weightKg, forKey: .weightKg)
        try container.encode(weightUnknown, forKey: .weightUnknown)
        try container.encode(sex.rawValue, forKey: .sex)
        try container.encode(goal.rawValue, forKey: .goal)
        try container.encode(activity.rawValue, forKey: .activity)
        try container.encode(diet.rawValue, forKey: .diet)
        try container.encode(allergies, forKey: .allergies)
        try container.encode(goals, forKey: .goals)
        try container.encode(Array(goalFocus), forKey: .goalFocus)
        try container.encode(notes, forKey: .notes)
    }
}
