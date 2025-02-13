// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Interface for managing customer consent related to E-Document functionality
/// </summary>
interface IConsentManager
{

    /// <summary>
    /// Obtains privacy consent from the customer.
    /// </summary>
    /// <returns>Returns true if the customer granted consent to the privacy notice ; otherwise, false.</returns>  
    /// <remarks>
    /// Displays a privacy consent message to the customer and saves customer's answer.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the default version of <c>ObtainPrivacyConsent</c> method:
    /// <code>
    /// procedure ObtainPrivacyConsent(): Boolean
    /// var
    ///     ConsentManagerDefaultImpl: Codeunit "Consent Manager Default Impl.";
    /// begin
    ///     exit(ConsentManagerDefaultImpl.ObtainPrivacyConsent());
    /// end;
    /// </code>
    /// </example>
    /// <example>
    /// This example demonstrates how to implement a custom <c>ObtainPrivacyConsent</c> method:
    /// <code>
    /// procedure ObtainPrivacyConsent(): Boolean
    /// var
    ///     CustConsentMgt: Codeunit "Customer Consent Mgt.";
    ///     CustomConsentMessageTxt: Text;
    /// begin
    ///     // CustomConsentMessageTxt := 'intialize your custom consent message';
    ///     exit(CustConsentMgt.ConfirmCustomConsent(CustomConsentMessageTxt));
    /// end;
    /// </code>
    /// </example>
    procedure ObtainPrivacyConsent(): Boolean

}