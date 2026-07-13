import Foundation

struct GenerateResponse: Decodable {
    let response: String
    let total_duration: UInt64?
    let eval_count: Int?
}

@main
struct GraniteOCR {
    static func main() async {
        guard (2...3).contains(CommandLine.arguments.count) else {
            FileHandle.standardError.write(Data("usage: granite_ocr IMAGE [OUTPUT]\n".utf8))
            exit(2)
        }

        do {
            let image = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
            let requestBody: [String: Any] = [
                "model": "ibm/granite-docling",
                "prompt": "Convert this page to docling.",
                "images": [image.base64EncodedString()],
                "stream": false,
                "options": [
                    "temperature": 0,
                    "num_predict": 8192
                ]
            ]

            var request = URLRequest(url: URL(string: "http://127.0.0.1:11434/api/generate")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw NSError(domain: "GraniteOCR", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Ollama request failed"
                ])
            }

            let result = try JSONDecoder().decode(GenerateResponse.self, from: data)
            if CommandLine.arguments.count == 3 {
                try result.response.write(
                    to: URL(fileURLWithPath: CommandLine.arguments[2]),
                    atomically: true,
                    encoding: .utf8
                )
            } else {
                print(result.response)
            }
            if let duration = result.total_duration, let count = result.eval_count {
                let seconds = Double(duration) / 1_000_000_000
                FileHandle.standardError.write(Data(String(format: "[%.2fs, %d output tokens]\n", seconds, count).utf8))
            }
        } catch {
            FileHandle.standardError.write(Data("Granite OCR failed: \(error)\n".utf8))
            exit(1)
        }
    }
}
