// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6392 "Continia Wizard Scenario"
{
    Access = Internal;
    Extensible = false;

    value(0; General)
    {
        Caption = 'General';
    }
    value(1; EditSubscriptionInfo)
    {
        Caption = 'Edit Company Contact Information';
    }
    value(2; EditParticipation)
    {
        Caption = 'Edit Participation and Profiles';
    }
}