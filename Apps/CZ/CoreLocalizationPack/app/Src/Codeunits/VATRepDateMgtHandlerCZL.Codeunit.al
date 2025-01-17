// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using System.Security.User;

codeunit 31129 "VAT Rep. Date Mgt. Handler CZL"
{
    Access = Internal;
    Permissions = tabledata "VAT Entry" = m;

    var
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Reporting Date';
        VATDateNotAllowedErr: Label 'You have no right to post VAT to the period.';
        VATControlReportAffectedMsg: Label 'The VAT Date was changed on VAT Entry registered in the VAT Control Report %1, which affected its values.\It will be necessary to check the VAT Control report manually.', Comment = '%1 = VAT Control Report No.';
        VIESDeclarationAffectedMsg: Label 'The VAT Date was changed on VAT Entry that can already be included in the VIES Declaration.\The VIES Declaration will need to be re-generated.';
        VATControlReportClosedErr: Label 'The VAT Entry is suggested in the released or closed VAT Control Report %1.\The VAT Date cannot be changed.', Comment = '%1 = VAT Control Report No.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnBeforeUpdateLinkedEntries', '', false, false)]
    local procedure CheckRelatedVATEntriesOnBeforeUpdateLinkedEntries(VATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    var
        PreviousVATEntry: Record "VAT Entry";
        RelatedVATEntry: Record "VAT Entry";
        TempVATEntry: Record "VAT Entry" temporary;
        ConfVATEntUpdateMgt: Codeunit "Conf. VAT Ent. Update Mgt. CZL";
        UserSetupAdvManagement: Codeunit "User Setup Adv. Management CZL";
    begin
        if IsHandled then
            exit;

        UserSetupAdvManagement.CheckVATDateChanging();
        CheckVATEntry(VATEntry);
        if PreviousVATEntry.Get(VATEntry."Entry No.") then
            CheckVATEntry(PreviousVATEntry);
        CheckVIESDeclaration(VATEntry);

        VATEntry.CalcFields("VAT Ctrl. Report No. CZL", "VAT Ctrl. Report Line No. CZL");
        if (VATEntry."VAT Ctrl. Report No. CZL" = '') and
           (VATEntry."VAT Ctrl. Report Line No. CZL" = 0)
        then
            exit;

        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        if not RelatedVATEntry.IsEmpty() then begin
            RelatedVATEntry.ToTemporaryCZL(TempVATEntry);
            if not ConfVATEntUpdateMgt.GetResponseOrDefault(TempVATEntry, true) then
                Error('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnAfterUpdateLinkedEntries', '', false, false)]
    local procedure UpdateAdvanceLedgerEntriesOnAfterUpdateLinkedEntries(VATEntry: Record "VAT Entry")
    var
        VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLine: Record "VAT Ctrl. Report Line CZL";
    begin
        case VATEntry.Type of
            VATEntry.Type::Sale:
                UpdateRelatedCustomerLedgerEntries(VATEntry);
            VATEntry.Type::Purchase:
                UpdateRelatedVendorLedgerEntries(VATEntry);
        end;

        VATEntry.CalcFields("VAT Ctrl. Report No. CZL", "VAT Ctrl. Report Line No. CZL");
        if (VATEntry."VAT Ctrl. Report No. CZL" = '') and
           (VATEntry."VAT Ctrl. Report Line No. CZL" = 0)
        then
            exit;

        UpdateRelatedVATEntries(VATEntry);

        VATCtrlReportHeader.Get(VATEntry."VAT Ctrl. Report No. CZL");
        VATCtrlReportHeader.TestField(Status, VATCtrlReportHeader.Status::Open);
        VATCtrlReportLine.Reset();
        VATCtrlReportLine.SetRange("VAT Ctrl. Report No.", VATEntry."VAT Ctrl. Report No. CZL");
        VATCtrlReportLine.SetRange("Document No.", VATEntry."Document No.");
        VATCtrlReportLine.SetRange("Posting Date", VATEntry."Posting Date");
        VATCtrlReportLine.SetFilter("Closed by Document No.", '<>%1', '');
        if not VATCtrlReportLine.IsEmpty() then
            Error(VATControlReportClosedErr, VATCtrlReportHeader."No.");
        VATCtrlReportLine.SetRange("Closed by Document No.");
        if not VATCtrlReportLine.IsEmpty() then begin
            if (VATEntry."VAT Reporting Date" >= VATCtrlReportHeader."Start Date") and
               (VATEntry."VAT Reporting Date" <= VATCtrlReportHeader."End Date")
            then
                VATCtrlReportLine.ModifyAll("VAT Date", VATEntry."VAT Reporting Date")
            else
                VATCtrlReportLine.DeleteAll(true);

            if GuiAllowed then
                Message(VATControlReportAffectedMsg, VATCtrlReportLine."VAT Ctrl. Report No.");
        end;
    end;

    local procedure CheckVATEntry(VATEntry: Record "VAT Entry")
    var
        VATDateHandler: Codeunit "VAT Date Handler CZL";
    begin
        VATEntry.TestField(Closed, false);
        if VATEntry."Original Doc. VAT Date CZL" > VATEntry."VAT Reporting Date" then
            VATEntry.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, VATEntry.FieldCaption(VATEntry."VAT Reporting Date")));
        VATDateHandler.VATPeriodCZLCheck(VATEntry."VAT Reporting Date");
        if not VATDateHandler.IsVATDateInAllowedPeriod(VATEntry."VAT Reporting Date") then
            Error(VATDateNotAllowedErr);
    end;

    local procedure CheckVIESDeclaration(VATEntry: Record "VAT Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATEntry.Type = VATEntry.Type::Sale then
            if VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
                if VATPostingSetup."VIES Sales CZL" then
                    Message(VIESDeclarationAffectedMsg);
    end;

    local procedure FilterRelatedVATEntries(VATEntry: Record "VAT Entry"; var RelatedVATEntry: Record "VAT Entry")
    begin
        RelatedVATEntry.SetFilter("Entry No.", '<>%1', VATEntry."Entry No.");
        RelatedVATEntry.SetFilter("VAT Reporting Date", '<>%1', VATEntry."VAT Reporting Date");
        RelatedVATEntry.SetRange("VAT Ctrl. Report No. CZL", VATEntry."VAT Ctrl. Report No. CZL");
        RelatedVATEntry.SetRange("VAT Ctrl. Report Line No. CZL", VATEntry."VAT Ctrl. Report Line No. CZL");
    end;

    local procedure FilterRelatedCustomerLedgerEntries(VATEntry: Record "VAT Entry"; var RelatedCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        RelatedCustLedgerEntry.SetFilter("VAT Date CZL", '<>%1', VATEntry."VAT Reporting Date");
        RelatedCustLedgerEntry.SetRange("Posting Date", VATEntry."Posting Date");
        RelatedCustLedgerEntry.SetRange("Document No.", VATEntry."Document No.");
    end;

    local procedure FilterRelatedVendorLedgerEntries(VATEntry: Record "VAT Entry"; var RelatedVendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        RelatedVendorLedgerEntry.SetFilter("VAT Date CZL", '<>%1', VATEntry."VAT Reporting Date");
        RelatedVendorLedgerEntry.SetRange("Posting Date", VATEntry."Posting Date");
        RelatedVendorLedgerEntry.SetRange("Document No.", VATEntry."Document No.");
    end;

    local procedure UpdateRelatedVATEntries(VATEntry: Record "VAT Entry")
    var
        RelatedVATEntry: Record "VAT Entry";
    begin
        RelatedVATEntry.LoadFields("Entry No.", "VAT Ctrl. Report No. CZL", "VAT Ctrl. Report Line No. CZL", "VAT Reporting Date");
        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        RelatedVATEntry.ModifyAll("VAT Reporting Date", VATEntry."VAT Reporting Date")
    end;

    local procedure UpdateRelatedCustomerLedgerEntries(VATEntry: Record "VAT Entry")
    var
        RelatedCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        RelatedCustLedgerEntry.LoadFields("Entry No.", "VAT Date CZL", "Posting Date", "Document No.");
        FilterRelatedCustomerLedgerEntries(VATEntry, RelatedCustLedgerEntry);
        RelatedCustLedgerEntry.ModifyAll("VAT Date CZL", VATEntry."VAT Reporting Date");
    end;

    local procedure UpdateRelatedVendorLedgerEntries(VATEntry: Record "VAT Entry")
    var
        RelatedVendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        RelatedVendorLedgerEntry.LoadFields("Entry No.", "VAT Date CZL", "Posting Date", "Document No.");
        FilterRelatedVendorLedgerEntries(VATEntry, RelatedVendorLedgerEntry);
        RelatedVendorLedgerEntry.ModifyAll("VAT Date CZL", VATEntry."VAT Reporting Date");
    end;
}
