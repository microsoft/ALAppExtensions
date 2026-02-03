// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

/// <summary>
/// The interface to retrieve IRS 1099 IRIS configuration values.
/// </summary>
interface "IRS 1099 IRIS Configuration"
{
    /// <summary>
    /// Gets the Transmitter Control Code (TCC).
    /// </summary>
    /// <returns>The TCC value.</returns>
    procedure GetTCC(): Text

    /// <summary>
    /// Gets the Software ID.
    /// </summary>
    /// <returns>The Software ID value.</returns>
    procedure GetSoftwareId(): Text

    /// <summary>
    /// Gets the Consent Application URL.
    /// </summary>
    /// <returns>The Consent App URL value.</returns>
    procedure GetConsentAppURL(): Text

    /// <summary>
    /// Gets the contact information.
    /// </summary>
    /// <param name="ContactName">Returns the contact name.</param>
    /// <param name="ContactEmail">Returns the contact email.</param>
    /// <param name="ContactPhone">Returns the contact phone number.</param>
    procedure GetContactInfo(var ContactName: Text; var ContactEmail: Text; var ContactPhone: Text)

    /// <summary>
    /// Determines if the system is running in test mode.
    /// </summary>
    /// <returns>True if running in test mode, false otherwise.</returns>
    procedure TestMode(): Boolean
}
