// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

page 18431 "Update Reference Inv. Journals"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Reference Invoice No.";
    Caption = 'Update Reference Inv. Journals';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the document number for the reference.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("Reference Invoice Nos."; Rec."Reference Invoice Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Reference Invoice number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RefInvNoMgt: Codeunit "Reference Invoice No. Mgt.";
                    begin
                        if Rec."Source Type" = Rec."Source Type"::Vendor then
                            RefInvNoMgt.UpdateReferenceInvoiceNoforPurchJournals(
                                Rec,
                                Rec."Document Type",
                                Rec."Document No.",
                                Rec."Journal Template Name",
                                Rec."Journal Batch Name")
                        else
                            RefInvNoMgt.UpdateReferenceInvoiceNoforSalesJournals(
                                Rec,
                                Rec."Document Type",
                                Rec."Document No.",
                                Rec."Journal Template Name",
                                Rec."Journal Batch Name");

                        if xRec."Reference Invoice Nos." <> '' then
                            if (xRec."Reference Invoice Nos." <> Rec."Reference Invoice Nos.") and Rec.Verified then
                                Error(RefNoAlterErr);
                    end;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the descriptive text that is associated with the reference document.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if the Source Type of the Entry is Customer,Vendor,Bank or G/L Account.';
                }
                field("Verified"; Rec.Verified)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the reference document is verified or not.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Verify)
            {
                ApplicationArea = All;
                Caption = 'Verify';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                Scope = Repeater;
                Tooltip = 'Specifies the process through which the reference document can be verified.';

                trigger OnAction()
                var
                    RefInvNoMgt: Codeunit "Reference Invoice No. Mgt.";
                begin
                    RefInvNoMgt.VerifyReferenceNoJournals(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec."Source Type" := SourceTypeExternal;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GenJournalLine: Record "Gen. Journal Line";
        RefInvNoMgt: Codeunit "Reference Invoice No. Mgt.";
        CheckValue: Boolean;
    begin
        ReferenceInvoiceNo.SetRange("Document No.", Rec."Document No.");
        ReferenceInvoiceNo.SetRange("Document Type", Rec."Document Type");
        ReferenceInvoiceNo.SetRange("Source No.", Rec."Source No.");
        ReferenceInvoiceNo.SetRange(Verified, false);
        if ReferenceInvoiceNo.FindFirst() then
            if Confirm(VerifyQst, false) then begin
                CheckValue := true;
                ReferenceInvoiceNo.DeleteAll();
            end else
                exit(false);

        CheckBlankLines();

        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then begin
            GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            GenJournalLine.SetRange("Document Type", Rec."Document Type");
            GenJournalLine.SetRange("Document No.", Rec."Document No.");
            if GenJournalLine.FindFirst() then
                if CheckValue then begin
                    GenJournalLine."RCM Exempt" := false;
                    GenJournalLine.Modify(true);
                end else begin
                    GenJournalLine."RCM Exempt" := RefInvNoMgt.CheckRCMExemptDateJournal(GenJournalLine);
                    GenJournalLine.Modify(true);
                end;
        end;
    end;

    var
        SourceTypeExternal: Enum "Party Type";
        VerifyQst: Label 'Do you want to delete unverified reference invoice no.?';
        ReferenceErr: Label 'Please Update Reference Invoice No for selected Document.';
        RefNoAlterErr: Label 'Reference Invoice No cannot be updated after verification.';

    procedure SetSourceType(SourceType: Enum "Party Type")
    begin
        SourceTypeExternal := SourceType;
    end;

    local procedure CheckBlankLines()
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        ReferenceInvoiceNo.SetRange("Document No.", Rec."Document No.");
        ReferenceInvoiceNo.SetRange("Document Type", Rec."Document Type");
        ReferenceInvoiceNo.SetRange("Source No.", Rec."Source No.");
        ReferenceInvoiceNo.SetRange(Verified, true);
        if ReferenceInvoiceNo.IsEmpty then begin
            VendorLedgerEntry.SetRange("Document No.", Rec."Document No.");
            if (not VendorLedgerEntry.IsEmpty) and (not Rec.Verified) then
                Error(ReferenceErr);

            CustLedgerEntry.SetRange("Document No.", Rec."Document No.");
            if (not CustLedgerEntry.IsEmpty) and (not Rec.Verified) then
                Error(ReferenceErr);
        end;
    end;
}
