import Foundation

/// Erori proprii pentru comunicarea JSON-RPC cu Odoo.
enum OdooRPCError: Error, LocalizedError {
    case transportError
    case invalidResponse
    case rpcError(String)

    var errorDescription: String? {
        switch self {
        case .transportError:
            return "Eroare de retea la comunicarea cu serverul Odoo."
        case .invalidResponse:
            return "Raspuns invalid de la serverul Odoo."
        case .rpcError(let message):
            return message
        }
    }
}

/// Client JSON-RPC minimal pentru API-ul Odoo expus la `{baseURL}/jsonrpc`.
///
/// Odoo expune acelasi API (common.authenticate, object.execute_kw) prin acest
/// endpoint generic JSON-RPC 2.0, mult mai simplu de consumat din Swift decat XML-RPC.
///
/// STRICT read-only din punct de vedere al utilizarii in acest proiect: clientul in
/// sine e generic (poate trimite orice metoda), dar apelantii (RealOdooClient) au
/// interdictie sa foloseasca altceva decat `authenticate`, `read`, `search_read`,
/// `fields_get` — niciodata `write`, `create`, `unlink`.
actor OdooRPCClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Efectueaza un apel JSON-RPC catre `{baseURL}/jsonrpc`.
    /// - Parameters:
    ///   - service: "common" sau "object".
    ///   - method: ex. "authenticate", "execute_kw".
    ///   - args: lista pozitionala de argumente, eterogena (String, Int, Bool, Array, Dictionary).
    /// - Returns: valoarea `result` din raspunsul JSON-RPC, tip `Any` (de obicei Int, Bool, Array sau Dictionary).
    func call(service: String, method: String, args: [Any]) async throws -> Any {
        let payload: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "service": service,
                "method": method,
                "args": args
            ],
            "id": 1
        ]

        guard JSONSerialization.isValidJSONObject(payload) else {
            throw OdooRPCError.transportError
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("jsonrpc"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw OdooRPCError.transportError
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw OdooRPCError.transportError
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw OdooRPCError.transportError
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OdooRPCError.invalidResponse
        }

        if let errorObject = json["error"] {
            let message = Self.errorMessage(from: errorObject)
            throw OdooRPCError.rpcError(message)
        }

        guard let result = json["result"] else {
            throw OdooRPCError.invalidResponse
        }

        return result
    }

    private static func errorMessage(from errorObject: Any) -> String {
        if let errorDict = errorObject as? [String: Any] {
            if let dataDict = errorDict["data"] as? [String: Any],
               let message = dataDict["message"] as? String {
                return message
            }
            if let message = errorDict["message"] as? String {
                return message
            }
        }
        if let data = try? JSONSerialization.data(withJSONObject: errorObject, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "Eroare necunoscuta de la Odoo."
    }
}
