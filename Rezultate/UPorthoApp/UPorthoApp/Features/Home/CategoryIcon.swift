import Foundation

enum CategoryIcon {
    static func symbolName(for categoryName: String) -> String {
        switch categoryName {
        case "Bracketi": return "circle.grid.2x2.fill"
        case "Tuburi si inele": return "circle.circle.fill"
        case "Arcuri": return "waveform.path"
        case "Adezivi": return "drop.fill"
        case "Elastomeri": return "link"
        case "Instrumentar": return "wrench.and.screwdriver.fill"
        case "Mini Implanturi": return "bolt.fill"
        case "Accesorii": return "puzzlepiece.fill"
        case "Fotografie": return "camera.fill"
        case "Ingrijire pacient": return "heart.text.square.fill"
        case "Echipamente": return "cross.case.fill"
        case "Laborator": return "flask.fill"
        case "Lichidare": return "tag.fill"
        default: return "square.grid.2x2"
        }
    }
}
