/// Базовый класс для сервисов API Яндекс Расписаний
class BaseAPIService {
    let client: Client
    let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }
}
