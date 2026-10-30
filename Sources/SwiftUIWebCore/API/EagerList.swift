public struct _EagerList: View {
    public let children: [AnyView]
    @Environment(\._lazyContainerAxis) private var axis

    public init(children: [AnyView]) { self.children = children }

    public var body: some View {
        let axis = axis
        ForEach(0..<children.count, id: \.self) { children[$0].environment(\._lazyContainerAxis, axis) }
            .environment(\._lazyContainerAxis, nil)
    }
}
