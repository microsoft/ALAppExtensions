// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 11621 "Create CH General Ledger Setup"
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
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.CHF());
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrecySwissLbl);
        GeneralLedgerSetup.Validate("Adjust for Payment Disc.", false);
        GeneralLedgerSetup.Validate("Prepayment Unrealized VAT", false);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrecySwissLbl: Label 'Swiss franc', MaxLength = 60;
}
