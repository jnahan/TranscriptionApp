import SwiftUI

struct AppButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.interSemiBold(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
            .padding(.horizontal, 64)
            .background(
                (isEnabled ? Color.black : Color.warmGray400)
                   .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .cornerRadius(.infinity)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 6)
    }
}
