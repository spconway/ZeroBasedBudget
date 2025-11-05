//
//  ValidationHelpersTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for ValidationHelpers utility
//  Tests input validation, error messages, and formatting functions
//

import XCTest
@testable import ZeroBasedBudget

final class ValidationHelpersTests: ZeroBasedBudgetTests {

    // MARK: - Name Validation Tests

    /// Test: Empty string is invalid name
    func test_isValidName_withEmptyString_returnsFalse() throws {
        // Arrange
        let emptyString = ""

        // Act
        let isValid = ValidationHelpers.isValidName(emptyString)

        // Assert
        XCTAssertFalse(isValid, "Empty string should not be valid name")
    }

    /// Test: Whitespace-only string is invalid name
    func test_isValidName_withWhitespaceOnly_returnsFalse() throws {
        // Arrange
        let whitespaceStrings = ["   ", "\t", "\n", "  \t\n  "]

        // Act & Assert
        for string in whitespaceStrings {
            let isValid = ValidationHelpers.isValidName(string)
            XCTAssertFalse(isValid, "Whitespace-only string '\(string)' should not be valid")
        }
    }

    /// Test: Valid name returns true
    func test_isValidName_withValidName_returnsTrue() throws {
        // Arrange
        let validNames = ["Groceries", "Rent", "Emergency Fund", "Gas & Electric"]

        // Act & Assert
        for name in validNames {
            let isValid = ValidationHelpers.isValidName(name)
            XCTAssertTrue(isValid, "'\(name)' should be valid")
        }
    }

    // MARK: - Category Name Validation Tests

    /// Test: Category name that's too long is invalid
    func test_isValidCategoryName_withTooLong_returnsFalse() throws {
        // Arrange
        let tooLongName = String(repeating: "a", count: 51) // 51 characters

        // Act
        let isValid = ValidationHelpers.isValidCategoryName(tooLongName)

        // Assert
        XCTAssertFalse(isValid, "Category name over 50 characters should be invalid")
    }

    /// Test: Valid category name returns true
    func test_isValidCategoryName_withValid_returnsTrue() throws {
        // Arrange
        let validName = String(repeating: "a", count: 50) // Exactly 50 characters

        // Act
        let isValid = ValidationHelpers.isValidCategoryName(validName)

        // Assert
        XCTAssertTrue(isValid, "Category name with 50 characters should be valid")
    }

    // MARK: - Description Validation Tests

    /// Test: Description that's too long is invalid
    func test_isValidDescription_withTooLong_returnsFalse() throws {
        // Arrange
        let tooLongDescription = String(repeating: "a", count: 201) // 201 characters

        // Act
        let isValid = ValidationHelpers.isValidDescription(tooLongDescription)

        // Assert
        XCTAssertFalse(isValid, "Description over 200 characters should be invalid")
    }

    /// Test: Valid description returns true
    func test_isValidDescription_withValid_returnsTrue() throws {
        // Arrange
        let validDescription = String(repeating: "a", count: 200) // Exactly 200 characters

        // Act
        let isValid = ValidationHelpers.isValidDescription(validDescription)

        // Assert
        XCTAssertTrue(isValid, "Description with 200 characters should be valid")
    }

    // MARK: - Amount Validation Tests

    /// Test: Positive amount is valid
    func test_isValidAmount_withPositive_returnsTrue() throws {
        // Arrange
        let amounts: [Decimal] = [0.01, 1, 100, 1000.50, 999999]

        // Act & Assert
        for amount in amounts {
            let isValid = ValidationHelpers.isValidAmount(amount)
            XCTAssertTrue(isValid, "\(amount) should be valid positive amount")
        }
    }

    /// Test: Zero amount is invalid for isValidAmount
    func test_isValidAmount_withZero_returnsFalse() throws {
        // Arrange
        let zero: Decimal = 0

        // Act
        let isValid = ValidationHelpers.isValidAmount(zero)

        // Assert
        XCTAssertFalse(isValid, "Zero should be invalid for isValidAmount (requires positive)")
    }

    /// Test: Zero amount is valid for isValidNonNegativeAmount
    /// YNAB Principle: Categories can have $0 budgeted
    func test_isValidNonNegativeAmount_withZero_returnsTrue() throws {
        // Arrange
        let zero: Decimal = 0

        // Act
        let isValid = ValidationHelpers.isValidNonNegativeAmount(zero)

        // Assert
        XCTAssertTrue(isValid, "Zero should be valid for non-negative amount (YNAB principle)")
    }

    /// Test: Reasonable amount is within valid range
    func test_isReasonableAmount_withinRange_returnsTrue() throws {
        // Arrange
        let amounts: [Decimal] = [0, 100, 1000, 100000, 1000000]

        // Act & Assert
        for amount in amounts {
            let isValid = ValidationHelpers.isReasonableAmount(amount)
            XCTAssertTrue(isValid, "\(amount) should be reasonable amount")
        }
    }

    /// Test: Amount exceeding maximum is unreasonable
    func test_isReasonableAmount_exceedsMax_returnsFalse() throws {
        // Arrange
        let tooLarge: Decimal = 1_000_000_001 // Over 1 billion

        // Act
        let isValid = ValidationHelpers.isReasonableAmount(tooLarge)

        // Assert
        XCTAssertFalse(isValid, "Amount over 1 billion should be unreasonable")
    }

    // MARK: - Formatting Tests

    /// Test: formatCurrency formats Decimal correctly
    func test_formatCurrency_withDecimal_formatsCorrectly() throws {
        // Arrange
        let testCases: [(Decimal, String)] = [
            (100, "$100.00"),
            (1234.56, "$1,234.56"),
            (0, "$0.00"),
            (0.50, "$0.50"),
        ]

        // Act & Assert
        for (amount, expected) in testCases {
            let formatted = ValidationHelpers.formatCurrency(amount)
            XCTAssertEqual(formatted, expected, "Amount \(amount) should format as \(expected)")
        }
    }

    /// Test: formatPercentage formats Double correctly
    func test_formatPercentage_withDouble_formatsCorrectly() throws {
        // Arrange
        let testCases: [(Double, String)] = [
            (0.0, "0.0%"),
            (0.5, "50.0%"),
            (0.756, "75.6%"),
            (1.0, "100.0%"),
            (1.25, "125.0%"),
        ]

        // Act & Assert
        for (value, expected) in testCases {
            let formatted = ValidationHelpers.formatPercentage(value)
            XCTAssertEqual(formatted, expected, "Value \(value) should format as \(expected)")
        }
    }
}
