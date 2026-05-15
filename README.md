# MindSculpt 🧠✨

<div align="center">
  <img width="350" height="350" alt="MindSculpt Logo" src="https://via.placeholder.com/350" /> 
</div>

[cite_start]**MindSculpt** es una solución de accesibilidad sensorial adaptativa diseñada para mitigar la sobrecarga sensorial en personas neurodivergentes, como aquellas con TEA o TDAH[cite: 49, 96]. [cite_start]Esta herramienta utiliza el ecosistema **Swift** para transformar estímulos ambientales complejos en una experiencia digital controlada, predecible y terapéutica[cite: 49, 95].

[cite_start]Proyecto desarrollado en la **Universidad de las Américas Puebla (UDLAP)** [cite: 38, 84] [cite_start]y presentado en la competencia **Infomatrix**[cite: 41, 78].

## Propuesta de Valor 💎
[cite_start]A diferencia de herramientas genéricas, MindSculpt se fundamenta en la **Teoría de la Integración Sensorial de Ayres**[cite: 133, 166]. [cite_start]Actúa como un puente tecnológico que facilita la autonomía y reduce la ansiedad en entornos visualmente abrumadores mediante la regulación sensorial inmediata[cite: 134].

## Flujo de Usuario: Ciclo de Regulación 🌊
La aplicación implementa una mecánica de interacción diseñada para guiar al usuario hacia la estabilidad emocional:

1. **Entrada Narrativa:** El usuario describe su estado anímico actual. Un modelo de IA (**FoundationModels**) analiza el texto para ubicar la emoción en un rango específico.
2. **Módulo de Regulación (El Cascarón):** La emoción se representa visualmente dentro de un cascarón que el usuario debe "romper" y calmar mediante gestos táctiles. Esta fase utiliza **vibraciones hápticas** para proporcionar una sensación física de control y calma.
3. **Árbol de Recuerdos:** Tras completar la regulación, la emoción se transforma en un elemento gráfico que se integra a un ecosistema visual, permitiendo un seguimiento del bienestar a largo plazo.

## Características Principales ✨
* [cite_start]**Escaneo Cromático en Tiempo Real:** Emplea el framework **Vision** para traducir colores capturados por la cámara en descripciones lingüísticas neutras [cite: 97, 183][cite_start], utilizando el espacio de color HSB para mayor precisión física[cite: 172, 179].
* [cite_start]**Paisajes Sonoros Adaptativos:** Generación de audio en frecuencias de regulación neurológica (8-12 Hz) para estabilizar la experiencia perceptiva[cite: 98, 169, 192].
* [cite_start]**Interfaz Minimalista:** Diseño de bajo contraste y reducida carga cognitiva basado en las directrices **WCAG 2.1**[cite: 168, 229].
* [cite_start]**Privacidad Local:** El procesamiento de imágenes y datos se realiza íntegramente en el dispositivo; no se almacenan ni transmiten datos a servidores externos[cite: 103, 264, 274].

## Tecnologías y Frameworks 🛠️
* [cite_start]**Lenguaje:** Swift[cite: 61].
* **Frameworks / SDKs:**
    * `FoundationModels`: Clasificación y análisis léxico de emociones.
    * [cite_start]`Vision`: Reconocimiento cromático y análisis de imagen en tiempo real[cite: 97, 153, 183].
    * [cite_start]`AVFoundation`: Gestión de sesiones de cámara y mezcla de audio adaptativo[cite: 56, 98, 184].
* **Kits de Apple:**
    * [cite_start]`SwiftUI`: Construcción de la interfaz de usuario inclusiva y declarativa[cite: 56, 95, 183].
    * `Core Haptics`: Motor de retroalimentación táctil para la validación sensorial.
* [cite_start]**Entorno de Desarrollo:** Swift Playgrounds 4[cite: 95, 262].

## Resultados de Validación 📊
[cite_start]En pruebas piloto con usuarios neurodivergentes [cite: 60, 267][cite_start], la aplicación obtuvo un promedio de satisfacción de **4.24/5**[cite: 63, 209].

| Indicador Evaluado | Puntuación | Aceptación (%) |
| :--- | :--- | :--- |
| **Respuesta Táctil (Haptics)** | **4.6** | [cite_start]**92%** [cite: 64, 200, 260] |
| Diseño Visual | 4.4 | [cite_start]88% [cite: 64, 260] |
| Interactividad | 4.2 | [cite_start]84% [cite: 199, 260] |
| Utilidad de Información | 4.0 | [cite_start]80% [cite: 199, 260] |
| Autonomía | 4.0 | [cite_start]80% [cite: 199, 260] |

## Requisitos de Ejecución 📱
* [cite_start]**Plataforma:** iOS / iPadOS 16.0 o superior[cite: 103, 262].
* **Hardware:** Se recomienda un dispositivo con motor háptico para la experiencia completa de regulación sensorial.
* [cite_start]**Permisos:** Requiere acceso a la **Cámara** (procesamiento local exclusivamente) para las funciones de escaneo[cite: 97, 263].

---
[cite_start]**Autor:** Elías Uriel Olmos Hernández [cite: 45, 83]
[cite_start]**Asesor:** Zobeida Jezabel Guzman Zavaleta [cite: 45, 84]
[cite_start]**Institución:** Universidad de las Américas Puebla (UDLAP) [cite: 38, 84]
