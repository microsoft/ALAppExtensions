// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The retention period interface provides functions to retrieve the date formula and calculate the expiration date based on a retention period record.
/// </summary>
Interface "Retention Period"
{
    /// <summary>Returns the date formula for a given retention period.</summary>
    /// <param name="RetentionPeriod">The record that has the retention period for which you want the date formula.</param>
    /// <returns>The date formula as a string in a language-independent format.</returns>
    procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"): Text

    /// <summary>Returns the date formula for a given retention period.</summary>
    /// <param name="RetentionPeriod">The record that has the retention period for which you want the date formula.</param>
    /// <param name="Translated">Indicates whether to return the date formula in a language-independent format or in the current language format.</param>
    /// <returns>The date formula as a string.</returns>
    procedure RetentionPeriodDateFormula(RetentionPeriod: Record "Retention Period"; Translated: Boolean): Text

    /// <summary>Returns the expiration date for a given retention period.</summary>
    /// <param name="RetentionPeriod">The record that has the retention period for which you want the expiration date. By default, the current date is used.</param>
    /// <returns>The expiration date.</returns>
    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"): Date

    /// <summary>Returns the expiration date for a given retention period.</summary>
    /// <param name="RetentionPeriod">The record that has the retention period for which you want the expiration date.</param>
    /// <param name="UseDate">The expiration date is calculated based on this date.</param>
    /// <returns>The expiration date.</returns>
    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDate: Date): Date

    /// <summary>Returns the expiration date and time for a given retention period.</summary>
    /// <param name="RetentionPeriod">The record that has the retention period for which you want the expiration date and time.</param>
    /// <param name="UseDateTime">The expiration date and time are calculated based on this date and time.</param>
    /// <returns>The expiration date and time.</returns>
    procedure CalculateExpirationDate(RetentionPeriod: Record "Retention Period"; UseDateTime: DateTime): DateTime
}