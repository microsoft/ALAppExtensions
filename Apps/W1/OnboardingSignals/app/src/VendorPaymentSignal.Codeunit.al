// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

        exit(VendorLedgerEntry.Count() >= OnboardingThreshold);
    end;
}
