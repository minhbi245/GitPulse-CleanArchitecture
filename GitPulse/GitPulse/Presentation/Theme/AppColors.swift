//
//  AppColors.swift
//  GitPulse
//

import UIKit

/// App color palette using Asset Catalog color sets that contain BOTH light and dark variants.
/// The system automatically picks the right variant based on UIUserInterfaceStyle.
/// No if/else needed — it just works.
///
/// If the Asset Catalog colors aren't set up, these fall back to system colors.
enum AppColors {

    /// Primary brand color.
    static var primary: UIColor {
        UIColor(named: "BrandPrimary") ?? .systemPurple
    }

    /// Secondary brand color.
    static var secondary: UIColor {
        UIColor(named: "BrandSecondary") ?? .systemGray
    }

    /// Tertiary/accent color.
    static var tertiary: UIColor {
        UIColor(named: "BrandTertiary") ?? .systemPink
    }

    // MARK: - Semantic Colors (already built into iOS)
    //
    // Use these system colors directly — no custom wrapper needed:
    //   UIColor.systemBackground
    //   UIColor.secondarySystemGroupedBackground
    //   UIColor.label
    //   UIColor.white
    //   UIColor.separator
    //   UIColor.tertiarySystemGroupedBackground
}
