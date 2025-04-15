// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 11485 "Create General Ledger Setup US"
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
        CreateCurrency: Codeunit "Create Currency";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Adjust for Payment Disc.", true);
        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"City+County+Post Code");
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.USD());
        GeneralLedgerSetup.Validate("Payment Tolerance %", 0.1);
        GeneralLedgerSetup.Validate("Max. Payment Tolerance Amount", 1);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Modify(true);
    end;
}
