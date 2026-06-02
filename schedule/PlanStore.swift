import Foundation

final class PlanStore {
    static let shared = PlanStore()

    private(set) var plans: [Plan] = []
    private let fileURL: URL

    private init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        fileURL = (documentsURL ?? FileManager.default.temporaryDirectory).appendingPathComponent("plans.json")
        load()
    }

    func plans(for dateKey: String) -> [Plan] {
        plans.filter { $0.dateKey == dateKey }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func upsert(_ plan: Plan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        } else {
            plans.append(plan)
        }
        save()
    }

    func delete(id: UUID) {
        plans.removeAll { $0.id == id }
        save()
    }

    func toggleDone(id: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == id }) else { return }
        plans[index].isDone.toggle()
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            plans = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Plan].self, from: data)
            plans = decoded
        } catch {
            plans = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(plans)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            return
        }
    }
}
