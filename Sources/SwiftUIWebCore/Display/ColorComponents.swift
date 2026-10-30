extension Color {
    /// The colour as sRGB red, green, blue and alpha, each 0 to 1, in the iOS profile's light appearance.
    public var _components: [Double] {
        var environment = EnvironmentValues()
        environment.platformProfile = .iOS
        let resolved = resolve(in: environment)
        return [resolved.red, resolved.green, resolved.blue, resolved.alpha]
    }
}
