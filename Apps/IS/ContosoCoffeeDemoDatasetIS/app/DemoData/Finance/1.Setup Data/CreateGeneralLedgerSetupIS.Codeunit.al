// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 14612 "Create General Ledger Setup IS"
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
        ValidateRecordFields(CreateCurrency.ISK(), LocalCurrencySymbolLbl, IcelandicKronaLbl, 0.001);
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; LocalCurrencySymbol: Text[10]; LocalCurrencyDescription: Text[60]; UnitAmountRoundingPrecision: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbol);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrencyDescription);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrencySymbolLbl: Label 'kr', Locked = true;
        IcelandicKronaLbl: Label 'Icelandic krona', MaxLength = 30;
}
