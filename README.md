# MindSculpt 🧠✨

<div align="center">
  <img width="350" height="350" alt="MindSculpt Logo" src="......" /> 
</div>

**MindSculpt** es una solución de accesibilidad sensorial adaptativa diseñada para mitigar la sobrecarga sensorial en personas neurodivergentes, como aquellas con TEA o TDAH. Esta herramienta utiliza el ecosistema **Swift** para transformar estímulos ambientales complejos en una experiencia digital controlada, predecible y terapéutica.

Proyecto desarrollado en la **Universidad de las Américas Puebla (UDLAP)** y presentado en la competencia **Infomatrix**.

## Propuesta de Valor 💎
A diferencia de herramientas genéricas, MindSculpt se fundamenta en la **Teoría de la Integración Sensorial de Ayres**. Actúa como un puente tecnológico que facilita la autonomía y reduce la ansiedad en entornos visualmente abrumadores mediante la regulación sensorial inmediata.

## Flujo de Usuario: Ciclo de Regulación 🌊
La aplicación implementa una mecánica de interacción diseñada para guiar al usuario hacia la estabilidad emocional:

1. **Entrada Narrativa:** El usuario describe su estado anímico actual. Un modelo de IA (**FoundationModels**) analiza el texto para ubicar la emoción en un rango específico.
2. **Módulo de Regulación (El Cascarón):** La emoción se representa visualmente dentro de un cascarón que el usuario debe "romper" y calmar mediante gestos táctiles. Esta fase utiliza **vibraciones hápticas** para proporcionar una sensación física de control y calma.
3. **Árbol de Recuerdos:** Tras completar la regulación, la emoción se transforma en un elemento gráfico que se integra a un ecosistema visual, permitiendo un seguimiento del bienestar a largo plazo.

## Características Principales ✨
* **Escaneo Cromático en Tiempo Real:** Emplea el framework **Vision** para traducir colores capturados por la cámara en descripciones lingüísticas neutras, utilizando el espacio de color HSB para mayor precisión física.
* **Paisajes Sonoros Adaptativos:** Generación de audio en frecuencias de regulación neurológica (8-12 Hz) para estabilizar la experiencia perceptiva.
* **Interfaz Minimalista:** Diseño de bajo contraste y reducida carga cognitiva basado en las directrices **WCAG 2.1**.
* **Privacidad Local:** El procesamiento de imágenes y datos se realiza íntegramente en el dispositivo; no se almacenan ni transmiten datos a servidores externos.

## Tecnologías y Frameworks 🛠️
* **Lenguaje:** Swift.
* **Frameworks / SDKs:**
    * `FoundationModels`: Clasificación y análisis léxico de emociones.
    * `Vision`: Reconocimiento cromático y análisis de imagen en tiempo real.
    * `AVFoundation`: Gestión de sesiones de cámara y mezcla de audio adaptativo.
* **Kits de Apple:**
    * `SwiftUI`: Construcción de la interfaz de usuario inclusiva y declarativa.
    * `Core Haptics`: Motor de retroalimentación táctil para la validación sensorial.
* **Entorno de Desarrollo:** Swift Playgrounds 4.

## Resultados de Validación 📊
En pruebas piloto con usuarios neurodivergentes, la aplicación obtuvo un promedio de satisfacción de **4.24/5**.

| Indicador Evaluado | Puntuación | Aceptación (%) |
| :--- | :--- | :--- |
| **Respuesta Táctil (Haptics)** | **4.6** | **92%**  |
| Diseño Visual | 4.4 | 88%  |
| Interactividad | 4.2 | 84%  |
| Utilidad de Información | 4.0 | 80%  |
| Autonomía | 4.0 | 80%  |

## Requisitos de Ejecución 📱
* **Plataforma:** iOS / iPadOS 16.0 o superior.
* **Hardware:** Se recomienda un dispositivo con motor háptico para la experiencia completa de regulación sensorial.
* **Permisos:** Requiere acceso a la **Cámara** (procesamiento local exclusivamente) para las funciones de escaneo.

---
**Autor:** Elías Uriel Olmos Hernández 
**Asesor:** Zobeida Jezabel Guzman Zavaleta 
**Institución:** Universidad de las Américas Puebla (UDLAP) 
