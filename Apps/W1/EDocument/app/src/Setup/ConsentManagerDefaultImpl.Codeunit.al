// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using System.Privacy;

codeunit 6171 "Consent Manager Default Impl." implements IConsentManager
{
    procedure ObtainPrivacyConsent(): Boolean
    var
        CustConsentMgt: Codeunit "Customer Consent Mgt.";
    begin
        exit(CustConsentMgt.ConfirmCustomConsent(ChooseIntegrationConsentTxt));
    end;

    var
        ChooseIntegrationConsentTxt: Label 'By choosing this option, you consent to use third party systems. These systems may have their own terms of use, license, pricing and privacy, and they may not meet the same compliance and security standards as Microsoft Dynamics 365 Business Central. Your privacy is important to us.';
}