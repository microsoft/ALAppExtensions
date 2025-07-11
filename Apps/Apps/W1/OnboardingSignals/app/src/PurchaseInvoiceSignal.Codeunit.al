// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20371 "Purchase Invoice Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Purch. Inv. Header" = r;

    procedure IsOnboarded(): Boolean
    var
        PostedPurchaseInvoice: Record "Purch. Inv. Header";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 5;

        exit(PostedPurchaseInvoice.Count() >= OnboardingThreshold);
    end;
}
