//
//  ContentView.swift
//  AnalyseDetente Watch App
//
//  Created by Gabriel Boudron on 10/01/2025.
//

import SwiftUI
import CoreMotion

// Instance globale de CMMotionManager
let motionManager = CMMotionManager()

// Fonction pour démarrer le suivi de l'accélération
func startTracking(updateHandler: @escaping (Double) -> Void) {
    if motionManager.isAccelerometerAvailable {
        motionManager.accelerometerUpdateInterval = 0.1 // Mise à jour toutes les 100 ms
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                print("Erreur : \(error.localizedDescription)")
                return
            }
            if let acceleration = data?.acceleration {
                // Transmet l'accélération en Y via le handler
                updateHandler(acceleration.y)
            }
        }
    } else {
        print("Accéléromètre non disponible.")
    }
}

// Fonction pour arrêter le suivi de l'accéléromètre
func stopTracking() {
    if motionManager.isAccelerometerActive {
        motionManager.stopAccelerometerUpdates()
        print("Suivi arrêté.")
    }
}

func calculateJumpHeight(time: Double) -> Double {
    let g = 9.81
    return 0.5 * g * pow(time, 2)
}

struct ContentView: View {
    @State private var jumpHeight: Double = 0.0
    @State private var isJumping: Bool = false
    @State private var startTime: Date? = nil

    let seuil = 0.8 // Seuil pour détecter un saut

    var body: some View {
        VStack {
            Text("Hauteur du saut : \(jumpHeight, specifier: "%.2f") mètres")
                .padding()

            Button("Démarrer le suivi") {
                startTracking { accelerationY in
                    // Détection du début d'un saut
                    if !isJumping && accelerationY > seuil {
                        isJumping = true
                        startTime = Date()
                        print("Début du saut détecté")
                    }

                    // Détection de la fin du saut
                    if isJumping && abs(accelerationY) < 0.2 {
                        if let start = startTime {
                            let jumpDuration = Date().timeIntervalSince(start)
                            jumpHeight = calculateJumpHeight(time: jumpDuration)
                            print("Fin du saut détecté : durée = \(jumpDuration) s, hauteur = \(jumpHeight) m")
                        }
                        isJumping = false
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
