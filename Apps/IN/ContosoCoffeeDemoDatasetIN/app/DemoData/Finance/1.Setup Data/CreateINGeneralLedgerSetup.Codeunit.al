// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 19023 "Create IN General Ledger Setup"
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
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        ValidateRecordFields(CreateCurrency.INR(), LocalCurrencySymbolLbl, LocalCurrencyDescriptionLbl, 0.001, CreateINNoSeries.PostedDistributionInvoice(), CreateINNoSeries.GSTCreditJournalAdjustment(), CreateINNoSeries.GSTSettlement(), CreateINNoSeries.TCSIH());
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; LocalCurrencySymbol: Text[10]; LocalCurrencyDescription: Text[60]; UnitAmountRoundingPrecision: Decimal; GSTDistributionNos: Code[20]; GSTCreditAdjJnlNos: Code[20]; GSTSettlementNos: Code[20]; TCSDebitNoteNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbol);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrencyDescription);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Validate("GST Distribution Nos.", GSTDistributionNos);
        GeneralLedgerSetup.Validate("GST Credit Adj. Jnl Nos.", GSTCreditAdjJnlNos);
        GeneralLedgerSetup.Validate("GST Settlement Nos.", GSTSettlementNos);
        GeneralLedgerSetup.Validate("TCS Debit Note No.", TCSDebitNoteNo);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrencySymbolLbl: Label '₹', Locked = true;
        LocalCurrencyDescriptionLbl: Label 'Indian Rupees', MaxLength = 60;
}
