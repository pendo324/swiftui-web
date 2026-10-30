extension EnvironmentValues {
    /// A colour of the app's scheme, resolved here (what a hosted UIKit view is given for a colour the environment names).
    public var _hostResolve: (Color) -> RGBA { { $0.resolve(in: self) } }
}
