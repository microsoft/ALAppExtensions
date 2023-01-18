// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 20370 "Customer Payment Signal" implements "Onboarding Signal"
{
    Access = Internal;
    Permissions = tabledata "Cust. Ledger Entry" = r;

    procedure IsOnboarded(): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OnboardingThreshold: Integer;
    begin
        OnboardingThreshold := 5;

        exit(CustLedgerEntry.Count() >= OnboardingThreshold);
    end;
}
