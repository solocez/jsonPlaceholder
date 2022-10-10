import ReSwift
import ReSwiftThunk

let thunkMiddleware: Middleware<AppState> = createThunkMiddleware()

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: AppState(),
    middleware: [thunkMiddleware]
)

final class StateManager {
    static let shared = StateManager()
    var store: Store<AppState> {
        mainStore
    }

    private init() {}
}
