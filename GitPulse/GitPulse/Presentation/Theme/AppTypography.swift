//
//  AppTypography.swift
//  GitPulse
//

import UIKit

/// App typography using `UIFont.preferredFont(forTextStyle:)` with Dynamic Type support.
///
/// Dynamic Type scales text based on the user's accessibility settings automatically.
///
/// Scale:
///   displayLarge  -> .largeTitle (34pt)
///   headlineLarge -> .title1 (28pt)
///   titleLarge    -> .title2 (22pt)
///   titleMedium   -> .headline (17pt semibold)
///   bodyLarge     -> .body (17pt)
///   bodyMedium    -> .callout (16pt)
///   bodySmall     -> .footnote (13pt)
///   labelLarge    -> .subheadline (15pt)
///   labelSmall    -> .caption1 (12pt)
enum AppTypography {

    static var displayLarge: UIFont { .preferredFont(forTextStyle: .largeTitle) }
    static var headlineLarge: UIFont { .preferredFont(forTextStyle: .title1) }
    static var titleLarge: UIFont { .preferredFont(forTextStyle: .title2) }
    static var titleMedium: UIFont { .preferredFont(forTextStyle: .headline) }
    static var bodyLarge: UIFont { .preferredFont(forTextStyle: .body) }
    static var bodyMedium: UIFont { .preferredFont(forTextStyle: .callout) }
    static var bodySmall: UIFont { .preferredFont(forTextStyle: .footnote) }
    static var labelLarge: UIFont { .preferredFont(forTextStyle: .subheadline) }
    static var labelSmall: UIFont { .preferredFont(forTextStyle: .caption1) }
}
