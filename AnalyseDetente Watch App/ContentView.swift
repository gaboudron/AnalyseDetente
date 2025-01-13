//
//  ContentView.swift
//  AnalyseDetente Watch App
//
//  Created by Gabriel Boudron on 10/01/2025.
//

import SwiftUI
import CoreMotion

// Logique de calcul : fonction pour déterminer la hauteur du saut
func calculateJumpHeight(time: Double) -> Double {
    let gravity = 9.81 // Accélération due à la gravité (m/s²)
    return (gravity * pow(time, 2)) / 8
}

let motionManager = CMMotionManager()

func startTracking() async throws -> CMAcceleration {
    return try await withCheckedThrowingContinuation { continuation in
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let error = error {
                    // Signale une erreur via la continuation
                    continuation.resume(throwing: error)
                } else if let acceleration = data?.acceleration {
                    // Renvoie les données via la continuation
                    continuation.resume(returning: acceleration)
                }
            }
        } else {
            // Signale une erreur si l'accéléromètre n'est pas disponible
            continuation.resume(throwing: NSError(domain: "CoreMotionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Accéléromètre non disponible"]))
        }
    }
}

struct ContentView: View {
    // Variable d'état pour stocker le résultat
    @State private var jumpHeight: Double = 0.0
    @State private var accelerationY: Double = 0.0

    var body: some View {
        VStack {
            // Affichage de la hauteur du saut
            /*Text("Détente verticale : \(jumpHeight, specifier: "%.2f") mètres")
                .padding()

            // Bouton pour simuler le calcul
            Button("Calculer") {
                // Simule un temps de vol et met à jour la hauteur
                let simulatedTime = 0.5 // Exemple : 0.5 seconde de temps de vol
                jumpHeight = calculateJumpHeight(time: simulatedTime)
            }
            .padding()*/
            Text("Accélération en Y : \(accelerationY, specifier: "%.2f")")
                        .padding()

            Button("Démarrer le suivi") {
                Task {
                    do {
                        let acceleration = try await startTracking()
                        // Mets à jour l'accélération en Y
                        accelerationY = acceleration.y
                    } catch {
                        print("Erreur : \(error.localizedDescription)")
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
