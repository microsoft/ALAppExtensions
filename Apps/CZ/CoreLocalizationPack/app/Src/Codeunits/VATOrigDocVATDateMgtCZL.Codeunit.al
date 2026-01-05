// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.History;
using System.Security.User;

codeunit 11733 "VAT Orig.Doc.VAT Date Mgt. CZL"
{
    Permissions = TableData "VAT Ctrl. Report Header CZL" = r,
                  TableData "VAT Ctrl. Report Line CZL" = rm,
                  TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm,
                  TableData "VAT Entry" = rm;

    trigger OnRun()
    begin

    end;

    var
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Reporting Date';
        VATControlReportClosedErr: Label 'The VAT Entry is suggested in the released or closed VAT Control Report %1.\The Original Document VAT Date cannot be changed.', Comment = '%1 = VAT Control Report No.';

    procedure UpdateOrigDocVATDate(VATEntry: Record "VAT Entry")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckOrigDocVATDateChanging();
        CheckVATEntry(VATEntry);
        CheckVATCtrlReport(VATEntry);

        if not ConfirmAffectedVATEntries(VATEntry) then
            Error('');

        UpdateVATEntries(VATEntry);
        UpdatePostedDocuments(VATEntry);
        UpdateVATCtrlReportLines(VATEntry);

        OnAfterUpdateOrigDocVATDate(VATEntry);
    end;

    local procedure CheckVATEntry(VATEntry: Record "VAT Entry")
    begin
        VATEntry.TestField(Closed, false);
        if VATEntry.Type = VATEntry.Type::Purchase then
            if VATEntry."Original Doc. VAT Date CZL" > VATEntry."VAT Reporting Date" then
                VATEntry.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, VATEntry.FieldCaption(VATEntry."VAT Reporting Date")));
    end;

    local procedure CheckVATCtrlReport(VATEntry: Record "VAT Entry")
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        VATEntry.CalcFields("VAT Ctrl. Report No. CZL");
        if VATEntry."VAT Ctrl. Report No. CZL" = '' then
            exit;

        VATCtrlReportHeaderCZL.Get(VATEntry."VAT Ctrl. Report No. CZL");
        VATCtrlReportHeaderCZL.TestField(Status, VATCtrlReportHeaderCZL.Status::Open);
        FilterRelatedVATCtrlReportLine(VATEntry, VATCtrlReportLineCZL);
        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '<>%1', '');
        if not VATCtrlReportLineCZL.IsEmpty() then
            Error(VATControlReportClosedErr, VATCtrlReportHeaderCZL."No.");
    end;

    local procedure ConfirmAffectedVATEntries(VATEntry: Record "VAT Entry"): Boolean
    var
        TempRelatedVATEntry: Record "VAT Entry" temporary;
        ConfVATEntUpdateMgtCZL: Codeunit "Conf. VAT Ent. Update Mgt. CZL";
    begin
        GetRelatedVATEntries(VATEntry, TempRelatedVATEntry);
        if TempRelatedVATEntry.IsEmpty() then
            exit(true);
        exit(ConfVATEntUpdateMgtCZL.GetResponseOrDefault(TempRelatedVATEntry, true));
    end;

    local procedure GetRelatedVATEntries(VATEntry: Record "VAT Entry"; var TempRelatedVATEntry: Record "VAT Entry" temporary)
    var
        RelatedVATEntry: Record "VAT Entry";
    begin
        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        if RelatedVATEntry.FindSet() then
            repeat
                AddToBuffer(RelatedVATEntry, TempRelatedVATEntry);
            until RelatedVATEntry.Next() = 0;

        FilterRelatedVATEntriesByVATCtrlReport(VATEntry, RelatedVATEntry);
        if RelatedVATEntry.FindSet() then
            repeat
                AddToBuffer(RelatedVATEntry, TempRelatedVATEntry);
            until RelatedVATEntry.Next() = 0;
    end;

    local procedure AddToBuffer(VATEntry: Record "VAT Entry"; var TempVATEntry: Record "VAT Entry")
    begin
        if TempVATEntry.Get(VATEntry."Entry No.") then
            exit;
        TempVATEntry := VATEntry;
        TempVATEntry.Insert();
    end;

    local procedure UpdateVATEntries(VATEntry: Record "VAT Entry")
    var
        RelatedVATEntry: Record "VAT Entry";
    begin
        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        RelatedVATEntry.ModifyAll("Original Doc. VAT Date CZL", VATEntry."Original Doc. VAT Date CZL");
        FilterRelatedVATEntriesByVATCtrlReport(VATEntry, RelatedVATEntry);
        RelatedVATEntry.ModifyAll("Original Doc. VAT Date CZL", VATEntry."Original Doc. VAT Date CZL");
    end;

    local procedure UpdatePostedDocuments(VATEntry: Record "VAT Entry")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        if VATEntry.Type = VATEntry.Type::Purchase then
            exit;

        case VATEntry."Document Type" of
            VATEntry."Document Type"::Invoice:
                begin
                    FilterPurchInvoiceHeader(VATEntry, PurchInvHeader);
                    PurchInvHeader.ModifyAll("Original Doc. VAT Date CZL", VATEntry."Original Doc. VAT Date CZL");
                end;
            VATEntry."Document Type"::"Credit Memo":
                begin
                    FilterPurchCrMemoHeader(VATEntry, PurchCrMemoHeader);
                    PurchCrMemoHeader.ModifyAll("Original Doc. VAT Date CZL", VATEntry."Original Doc. VAT Date CZL");
                end;
        end;
    end;

    local procedure UpdateVATCtrlReportLines(VATEntry: Record "VAT Entry")
    var
        RelatedVATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        VATEntry.CalcFields("VAT Ctrl. Report No. CZL");
        if VATEntry."VAT Ctrl. Report No. CZL" = '' then
            exit;

        FilterRelatedVATCtrlReportLine(VATEntry, RelatedVATCtrlReportLineCZL);
        RelatedVATCtrlReportLineCZL.ModifyAll("Original Document VAT Date", VATEntry."Original Doc. VAT Date CZL");
    end;

    local procedure FilterRelatedVATCtrlReportLine(VATEntry: Record "VAT Entry"; var RelatedVATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
        RelatedVATCtrlReportLineCZL.Reset();
        RelatedVATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATEntry."VAT Ctrl. Report No. CZL");
        RelatedVATCtrlReportLineCZL.SetRange("Document No.", VATEntry."Document No.");
        RelatedVATCtrlReportLineCZL.SetRange("Posting Date", VATEntry."Posting Date");
    end;

    local procedure FilterRelatedVATEntries(VATEntry: Record "VAT Entry"; var RelatedVATEntry: Record "VAT Entry")
    begin
        RelatedVATEntry.Reset();
        RelatedVATEntry.SetFilter("Entry No.", '<>%1', VATEntry."Entry No.");
        RelatedVATEntry.SetRange(Type, VATEntry.Type);
        RelatedVATEntry.SetRange("Document No.", VATEntry."Document No.");
        RelatedVATEntry.SetRange("Posting Date", VATEntry."Posting Date");
    end;

    local procedure FilterRelatedVATEntriesByVATCtrlReport(VATEntry: Record "VAT Entry"; var RelatedVATEntry: Record "VAT Entry")
    begin
        RelatedVATEntry.Reset();
        RelatedVATEntry.SetFilter("Entry No.", '<>%1', VATEntry."Entry No.");
        RelatedVATEntry.SetFilter("Original Doc. VAT Date CZL", '<>%1', VATEntry."Original Doc. VAT Date CZL");
        RelatedVATEntry.SetRange("VAT Ctrl. Report No. CZL", VATEntry."VAT Ctrl. Report No. CZL");
        RelatedVATEntry.SetRange("VAT Ctrl. Report Line No. CZL", VATEntry."VAT Ctrl. Report Line No. CZL");
    end;

    local procedure FilterPurchInvoiceHeader(VATEntry: Record "VAT Entry"; var PurchInvoiceHeader: Record "Purch. Inv. Header")
    begin
        PurchInvoiceHeader.Reset();
        PurchInvoiceHeader.SetRange("No.", VATEntry."Document No.");
        PurchInvoiceHeader.SetRange("Posting Date", VATEntry."Posting Date");
        PurchInvoiceHeader.SetRange("Vendor Invoice No.", VATEntry."External Document No.");
    end;

    local procedure FilterPurchCrMemoHeader(VATEntry: Record "VAT Entry"; var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHeader.Reset();
        PurchCrMemoHeader.SetRange("No.", VATEntry."Document No.");
        PurchCrMemoHeader.SetRange("Posting Date", VATEntry."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateOrigDocVATDate(VATEntry: Record "VAT Entry")
    begin
    end;
}