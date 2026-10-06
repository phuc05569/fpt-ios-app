import Foundation
import Testing
import UIKit
@testable import Campus

struct HomeHeaderTests {
    @Test func avatarImageIsBundled() {
        #expect(UIImage(named: "FPTAvatar") != nil)
    }

    // Vietnamese text must be stored precomposed so it renders the same everywhere.
    @Test func vietnameseNameIsNormalisedAndCorrect() {
        #expect(HomeProfileHeader.name == "Vũ Hoàng Phúc")
        #expect(HomeProfileHeader.name == HomeProfileHeader.name.precomposedStringWithCanonicalMapping)
        #expect(HomeProfileHeader.university == "FPT University")
    }
}
