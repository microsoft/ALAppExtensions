// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

#if not CLEAN24
using Microsoft.Finance.GeneralLedger.Ledger;
#endif
#if not CLEAN22
using Microsoft.Finance.GeneralLedger.Posting;
#endif
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Document;
#if not CLEAN24
using Microsoft.Purchases.Payables;
#endif
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
#if not CLEAN24
using Microsoft.Sales.Receivables;
#endif
using Microsoft.Service.Document;

codeunit 11746 "Gen. Journal Line Handler CZL"
{
    Permissions = tabledata "VAT Entry" = d,
                  tabledata "G/L Entry - VAT Entry Link" = d;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineDocumentTypeValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Bill-to/Pay-to No.', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineBiilToPayToNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;
#if not CLEAN22

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforeGenJnlLinePostingDateValidate(var Rec: Record "Gen. Journal Line")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
#pragma warning disable AL0432
        Rec.Validate("VAT Date CZL", Rec."Posting Date");
#pragma warning restore AL0432
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Bal. Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineBalAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetUpNewLine', '', false, false)]
    local procedure UpdateVatDateOnAfterGenJnlLineSetUpNewLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then begin
            GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
            if GenJournalLine."VAT Date CZL" = 0D then
                GenJournalLine.Validate("VAT Date CZL", WorkDate());
            GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
            exit;
        end;
#pragma warning restore AL0432
#endif
        if GenJournalLine."VAT Reporting Date" = 0D then
            GenJournalLine."VAT Reporting Date" := WorkDate();
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterUpdateCountryCodeAndVATRegNo', '', false, false)]
    local procedure UpdateRegNoOnAfterUpdateCountryCodeAndVATRegNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BillPaySellBuyNo: Code[20];
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            BillPaySellBuyNo := GenJournalLine."Bill-to/Pay-to No.";
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Sell-to/Buy-from No." then
            BillPaySellBuyNo := GenJournalLine."Sell-to/Buy-from No.";

        if BillPaySellBuyNo = '' then begin
            GenJournalLine."Registration No. CZL" := '';
            exit;
        end;
        case true of
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer):
                begin
                    Customer.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
                end;
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor):
                begin
                    Vendor.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromSalesHeader(var GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := SalesHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := SalesHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromPurchHeader(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No. CZL";
#if not CLEAN24
#pragma warning disable AL0432
        if not PurchaseHeader.IsEU3PartyTradeFeatureEnabled() then
            GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3-Party Trade CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromServHeader', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromServHeader(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := ServiceHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := ServiceHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := ServiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := ServiceHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Posting Group" := ServiceHeader."Customer Posting Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnGetDocumentBalanceOnBeforeCalcBalance', '', false, false)]
    local procedure TestNotCheckDocTypeCZLOnGetDocumentBalanceOnBeforeCalcBalance(var GenJournalLine: Record "Gen. Journal Line"; GenJnlTemplate: Record "Gen. Journal Template")
    begin
        if GenJnlTemplate."Not Check Doc. Type CZL" then
            GenJournalLine.SetRange("Document Type");
    end;

#if not CLEAN24
    [Obsolete('Replaced by GetReceivablesAccNoCZL function in Cust. Ledger Entry table.', '24.0')]
    procedure GetReceivablesAccNo(CustLedgerEntry: Record "Cust. Ledger Entry"): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
#pragma warning disable AL0432
        OnBeforeGetReceivablesAccountNo(CustLedgerEntry, GLAccountNo, IsHandled);
#pragma warning restore AL0432
        if IsHandled then
            exit(GLAccountNo);

        CustLedgerEntry.TestField("Customer Posting Group");
        CustomerPostingGroup.Get(CustLedgerEntry."Customer Posting Group");
        CustomerPostingGroup.TestField("Receivables Account");
        exit(CustomerPostingGroup.GetReceivablesAccount());
    end;

    [Obsolete('Replaced by GetPayablesAccNoCZL function in Vendor Ledger Entry table.', '24.0')]
    procedure GetPayablesAccNo(VendorLedgerEntry: Record "Vendor Ledger Entry"): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
#pragma warning disable AL0432
        OnBeforeGetPayablesAccountNo(VendorLedgerEntry, GLAccountNo, IsHandled);
#pragma warning restore AL0432
        if IsHandled then
            exit(GLAccountNo);

        VendorLedgerEntry.TestField("Vendor Posting Group");
        VendorPostingGroup.Get(VendorLedgerEntry."Vendor Posting Group");
        VendorPostingGroup.TestField("Payables Account");
        exit(VendorPostingGroup.GetPayablesAccount());
    end;

#endif
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostApplyCustLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostApplyCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostUnapplyCustLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostUnapplyCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
    end;

#pragma warning restore AL0432
#endif
#if not CLEAN24
    internal procedure UpdateVATAmountOnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        IsHandled: Boolean;
    begin
#pragma warning disable AL0432
        OnBeforeUpdateVATAmountOnAfterInitVAT(GenJournalLine, GLEntry, IsHandled);
#pragma warning restore AL0432
        if IsHandled then
            exit;

        if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" ") or
           (GenJournalLine."VAT Posting" <> GenJournalLine."VAT Posting"::"Automatic VAT Entry") or
           (GenJournalLine."VAT Calculation Type" <> GenJournalLine."VAT Calculation Type"::"Normal VAT") or
           (GenJournalLine."VAT Difference" <> 0)
        then
            exit;

        GLEntry.Amount := GenJournalLine."VAT Base Amount (LCY)";
        GLEntry."VAT Amount" := GenJournalLine."VAT Amount (LCY)";
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmt(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmt(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
    end;

#if not CLEAN24
    [Obsolete('Replaced by OnBeforeGetReceivablesAccountNoCZL function in "Cust. Ledger Entry" table.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReceivablesAccountNo(CustLedgerEntry: Record "Cust. Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnBeforeGetPayablesAccountNoCZL event in "Vendor Ledger Entry" table.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPayablesAccountNo(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnBeforeUpdateVATAmountOnAfterInitVAT event in "Gen.Jnl. Post Line Handler CZL" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATAmountOnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;
#endif
}
