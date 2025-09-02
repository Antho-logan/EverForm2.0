#if canImport(UIKit)
import UIKit

// MARK: - Profile Model
final class UIKitProfileStore {
    static let shared = UIKitProfileStore()
    
    // Personal Info
    var name: String = "Alex Chen"
    var email: String = "alex@example.com"
    var phone: String = ""
    var birthday: Date = .now
    var sex: Sex = .male
    
    // Body Metrics
    var heightCm: Double = 170.0
    var weightKg: Double = 70.0
    var unitSystem: UnitSystem = .metric
    
    // Goals
    var stepsTarget: Int = 10000
    var caloriesTarget: Int = 2400
    var sleepHoursTarget: Double = 8.0
    var waterMlTarget: Int = 2000
    
    // Preferences
    var notificationsEnabled: Bool = true
    
    // Enums
    enum Sex: String, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    enum UnitSystem: String, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    private init() {
        load()
    }
    
    private func load() {
        let defaults = UserDefaults.standard
        
        name = defaults.string(forKey: "profile_name") ?? "Alex Chen"
        email = defaults.string(forKey: "profile_email") ?? "alex@example.com"
        phone = defaults.string(forKey: "profile_phone") ?? ""
        birthday = defaults.object(forKey: "profile_birthday") as? Date ?? .now
        sex = Sex(rawValue: defaults.string(forKey: "profile_sex") ?? "") ?? .male
        heightCm = defaults.double(forKey: "profile_height_cm")
        weightKg = defaults.double(forKey: "profile_weight_kg")
        unitSystem = UnitSystem(rawValue: defaults.string(forKey: "profile_unit_system") ?? "") ?? .metric
        stepsTarget = defaults.integer(forKey: "profile_steps_target")
        caloriesTarget = defaults.integer(forKey: "profile_calories_target")
        sleepHoursTarget = defaults.double(forKey: "profile_sleep_hours_target")
        waterMlTarget = defaults.integer(forKey: "profile_water_ml_target")
        notificationsEnabled = defaults.bool(forKey: "profile_notifications_enabled")
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(name, forKey: "profile_name")
        defaults.set(email, forKey: "profile_email")
        defaults.set(phone, forKey: "profile_phone")
        defaults.set(birthday, forKey: "profile_birthday")
        defaults.set(sex.rawValue, forKey: "profile_sex")
        defaults.set(heightCm, forKey: "profile_height_cm")
        defaults.set(weightKg, forKey: "profile_weight_kg")
        defaults.set(unitSystem.rawValue, forKey: "profile_unit_system")
        defaults.set(stepsTarget, forKey: "profile_steps_target")
        defaults.set(caloriesTarget, forKey: "profile_calories_target")
        defaults.set(sleepHoursTarget, forKey: "profile_sleep_hours_target")
        defaults.set(waterMlTarget, forKey: "profile_water_ml_target")
        defaults.set(notificationsEnabled, forKey: "profile_notifications_enabled")
    }
    
    // Computed properties for display
    var heightDisplay: String {
        if unitSystem == .metric {
            return String(format: "%.0f cm", heightCm)
        } else {
            let inches = heightCm * 0.393701
            let feet = Int(inches / 12)
            let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(remainingInches)\""
        }
    }
    
    var weightDisplay: String {
        if unitSystem == .metric {
            return String(format: "%.1f kg", weightKg)
        } else {
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lb", pounds)
        }
    }
    
    var waterDisplay: String {
        if unitSystem == .metric {
            return "\(waterMlTarget) ml"
        } else {
            let oz = Double(waterMlTarget) * 0.033814
            return String(format: "%.0f oz", oz)
        }
    }
}

// MARK: - Profile View Controller
final class ProfileViewController: UITableViewController {
    private let store: UIKitProfileStore
    private let sections: [Section] = [
        .personalInfo,
        .bodyMetrics,
        .goals,
        .preferences
    ]
    
    enum Section: Int, CaseIterable {
        case personalInfo = 0
        case bodyMetrics = 1
        case goals = 2
        case preferences = 3
        
        var title: String {
            switch self {
            case .personalInfo: return "Personal Info"
            case .bodyMetrics: return "Body Metrics"
            case .goals: return "Goals"
            case .preferences: return "Preferences"
            }
        }
        
        var rowCount: Int {
            switch self {
            case .personalInfo: return 5
            case .bodyMetrics: return 3
            case .goals: return 4
            case .preferences: return 1
            }
        }
    }
    
    init(store: UIKitProfileStore = UIKitProfileStore.shared) {
        self.store = store
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .personalInfo:
            return personalInfoCell(for: indexPath)
        case .bodyMetrics:
            return bodyMetricsCell(for: indexPath)
        case .goals:
            return goalsCell(for: indexPath)
        case .preferences:
            return preferencesCell(for: indexPath)
        }
    }
    
    private func personalInfoCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            config.image = UIImage(systemName: "person")
            config.text = "Name"
            config.secondaryText = store.name
        case 1:
            config.image = UIImage(systemName: "envelope")
            config.text = "Email"
            config.secondaryText = store.email
        case 2:
            config.image = UIImage(systemName: "phone")
            config.text = "Phone"
            config.secondaryText = store.phone.isEmpty ? "Not set" : store.phone
        case 3:
            config.image = UIImage(systemName: "calendar")
            config.text = "Birthday"
            config.secondaryText = store.birthday.formatted(date: .abbreviated, time: .omitted)
        case 4:
            config.image = UIImage(systemName: "figure")
            config.text = "Sex"
            config.secondaryText = store.sex.rawValue
        default:
            break
        }
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func bodyMetricsCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            config.image = UIImage(systemName: "ruler")
            config.text = "Height"
            config.secondaryText = store.heightDisplay
        case 1:
            config.image = UIImage(systemName: "scalemass")
            config.text = "Weight"
            config.secondaryText = store.weightDisplay
        case 2:
            config.image = UIImage(systemName: "gear")
            config.text = "Units"
            config.secondaryText = store.unitSystem.rawValue
        default:
            break
        }
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func goalsCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            config.image = UIImage(systemName: "figure.walk")
            config.text = "Steps"
            config.secondaryText = store.stepsTarget.formatted(.number.notation(.compactName))
        case 1:
            config.image = UIImage(systemName: "flame")
            config.text = "Calories"
            config.secondaryText = "\(store.caloriesTarget) kcal"
        case 2:
            config.image = UIImage(systemName: "bed.double")
            config.text = "Sleep"
            config.secondaryText = "\(store.sleepHoursTarget) hrs"
        case 3:
            config.image = UIImage(systemName: "drop")
            config.text = "Hydration"
            config.secondaryText = store.waterDisplay
        default:
            break
        }
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func preferencesCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        cell.configure(
            title: "Notifications",
            icon: UIImage(systemName: "bell"),
            isOn: store.notificationsEnabled
        ) { isOn in
            self.store.notificationsEnabled = isOn
            self.store.save()
        }
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .personalInfo:
            handlePersonalInfoSelection(at: indexPath.row)
        case .bodyMetrics:
            handleBodyMetricsSelection(at: indexPath.row)
        case .goals:
            handleGoalsSelection(at: indexPath.row)
        case .preferences:
            break
        }
    }
    
    private func handlePersonalInfoSelection(at row: Int) {
        // Placeholder for editing functionality
        let alert = UIAlertController(title: "Edit", message: "Editing functionality coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleBodyMetricsSelection(at row: Int) {
        // Placeholder for editing functionality
        let alert = UIAlertController(title: "Edit", message: "Editing functionality coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleGoalsSelection(at row: Int) {
        // Placeholder for editing functionality
        let alert = UIAlertController(title: "Edit", message: "Editing functionality coming soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Switch Table View Cell
class SwitchTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let switchControl = UISwitch()
    
    var onSwitchChange: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configure(title: String, icon: UIImage?, isOn: Bool, onSwitchChange: @escaping (Bool) -> Void) {
        titleLabel.text = title
        iconImageView.image = icon
        switchControl.isOn = isOn
        self.onSwitchChange = onSwitchChange
    }
    
    @objc private func switchValueChanged() {
        onSwitchChange?(switchControl.isOn)
    }
}

#endif
