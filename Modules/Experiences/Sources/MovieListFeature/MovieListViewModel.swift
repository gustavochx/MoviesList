import MoviesDomainInterface
import Foundation
import Observation

@MainActor
@Observable
final class MovieListViewModel {
    enum State: Equatable {
        case loading
        case empty
        case loaded([Movie])
        case failed(message: String)
    }

    private(set) var state: State = .loading

    @ObservationIgnored private let interactor: MovieListInteracting

    init(interactor: MovieListInteracting) {
        self.interactor = interactor
    }

    func load() async {
        do {
            let items = try await interactor.loadMovies()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .failed(message: "Couldn't load. Try again.")
        }
    }
}
