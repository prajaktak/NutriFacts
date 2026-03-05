// AIAgentService.swift
// NutriFacts

import UIKit

/// Routes AI requests to the online or offline service based on connectivity,
/// falling back to the other service if the primary fails.
final class AIAgentService: AIServiceProtocol {

    private let onlineService: AIServiceProtocol
    private let offlineService: AIServiceProtocol
    private let connectivityMonitor: ConnectivityMonitoring

    init(
        onlineService: AIServiceProtocol,
        offlineService: AIServiceProtocol,
        connectivityMonitor: ConnectivityMonitoring
    ) {
        self.onlineService = onlineService
        self.offlineService = offlineService
        self.connectivityMonitor = connectivityMonitor
    }

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        if connectivityMonitor.isOnline {
            return try await onlineService.lookupNutrition(query: query)
        }
        do {
            return try await offlineService.lookupNutrition(query: query)
        } catch {
            throw AppError.aiUnavailable
        }
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        if connectivityMonitor.isOnline {
            return try await onlineService.lookupNutrition(image: image)
        }
        do {
            return try await offlineService.lookupNutrition(image: image)
        } catch {
            throw AppError.aiUnavailable
        }
    }
}
