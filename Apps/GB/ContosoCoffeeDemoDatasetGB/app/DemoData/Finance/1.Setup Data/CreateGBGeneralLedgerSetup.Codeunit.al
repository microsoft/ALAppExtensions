// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 10518 "Create GB General Ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"City+County+Post Code");
        GeneralLedgerSetup.Validate("Hide Payment Method Code", true);
        GeneralLedgerSetup.Validate("Payment Tolerance %", 0.1);
        GeneralLedgerSetup.Validate("Max. Payment Tolerance Amount", 1);
        GeneralLedgerSetup.Modify(true);
    end;

    internal procedure UpdateMaxVATDifferenceAllowedOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Max. VAT Difference Allowed", 10);
        GeneralLedgerSetup.Modify(true);
    end;
}
