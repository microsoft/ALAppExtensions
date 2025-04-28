// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 13431 "Create General Ledger Setup FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        ValidateRecordFields(CreateCurrency.EUR(), 0.001, true, true);
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; UnitAmountRoundingPrecision: Decimal; EMUCurrency: Boolean; DataCheck: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Enable Data Check", DataCheck);
        GeneralLedgerSetup.Validate("EMU Currency", EMUCurrency);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Modify(true);
    end;
}
