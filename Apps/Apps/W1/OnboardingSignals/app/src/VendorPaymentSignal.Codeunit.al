// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20375 "Vendor Payment Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Vendor Ledger Entry" = r;

    procedure IsOnboarded(): Boolean
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 5;

        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);

        exit(VendorLedgerEntry.Count() >= OnboardingThreshold);
    end;
}
