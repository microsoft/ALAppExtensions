// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;

page 18206 "GST Distribution Reversal"
{
    Caption = 'GST Distribution Reversal';
    PageType = Document;
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;
    SourceTable = "GST Distribution Header";
    SourceTableView = where(Reversal = filter(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.UPDATE();
                    end;
                }
                field("ISD Document Type"; Rec."ISD Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of Input service distribution entry.';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies location code from which input will be distributed, input service distribution field needs to be marked true for this location.';
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies from which GSTIN No. input credit will be distributed.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Reversal Invoice No."; Rec."Reversal Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice number which needs to be reversed.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Total Amout Applied for Dist."; Rec."Total Amout Applied for Dist.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount to be applied for distribution on the basis of apply invoice.';
                }
            }
            part(Subform; "GST Distribution Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Distribution No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                action(Dimensions)
                {
                    AccessByPermission = TableData "Dimension" = R;
                    Caption = 'Dimensions';
                    ApplicationArea = Basic, Suite;
                    Image = Dimensions;
                    Promoted = false;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Specifies the process to view or edit dimentions, that can be assigned to transactions to distribute cost and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group("F&unction")
            {
                Caption = 'F&unction';
                Image = "Action";
                action("Apply Entries")
                {
                    Caption = 'Apply Entries';
                    ApplicationArea = Basic, Suite;
                    Enabled = ApplyBtnEnable;
                    Image = ApplyEntries;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Apply the amount on journal line to the relevant posted entry, this updated the posted document.';

                    trigger OnAction()
                    begin
                        ApplyEntries();
                    end;
                }

                action(Post)
                {
                    Caption = 'Post';
                    ApplicationArea = Basic, Suite;
                    Enabled = ApplyBtnEnable;
                    Image = ApplyEntries;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Finalize the document or journal by posting the amounts to the related accounts in your company books.';

                    trigger OnAction()
                    var
                        GSTDistributionReversalMsg: Label 'Distribution Reversal Lines Posted successfully.';
                    begin
                        GSTDistribution.InsertDistComponentAmount(Rec."No.", true);
                        if GSTDistribution.PostGSTDistribution(Rec."No.", Rec."Reversal Invoice No.", true) then begin
                            Message(GSTDistributionReversalMsg);
                            CurrPage.CLOSE();
                        end;
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Reversal := true;
    end;

    trigger OnOpenPage()
    begin
        EnableFillBufferLine();
    end;

    local procedure ApplyEntries()
    var
        GSTDistributionLine: Record "GST Distribution Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry2: Record "Detailed GST Ledger Entry";
        TempDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry" temporary;
        NoSelectErr: Label 'All components of same Document Line No. must be selected for distribution. You must select %1 for Document Type: %2 Document No.: %3 Document Line No.: %4 GST Component Code %5.', Comment = '%1 = Field Name, %2 = Document Type, %3 = Document No., %4 = Document Line No., %5 = GST Component Code';
    begin
        TempDetailedGSTLedgerEntry.DeleteAll();
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Dist. Document No.", Rec."Reversal Invoice No.");
        DetailedGSTLedgerEntry.SetRange(Distributed, true);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                TempDetailedGSTLedgerEntry := DetailedGSTLedgerEntry;
                if DetailedGSTLedgerEntry."Dist. Reverse Document No." = Rec."No." then
                    TempDetailedGSTLedgerEntry."Dist. Input GST Credit" := true;
                TempDetailedGSTLedgerEntry.Insert();
            until DetailedGSTLedgerEntry.Next() = 0;

        if Page.RunModal(Page::"Dist. Input GST Credit", TempDetailedGSTLedgerEntry) = Action::LookupOK then begin
            TempDetailedGSTLedgerEntry.FindSet();
            repeat
                DetailedGSTLedgerEntry.Get(TempDetailedGSTLedgerEntry."Entry No.");
                if TempDetailedGSTLedgerEntry."Dist. Input GST Credit" then
                    DetailedGSTLedgerEntry."Dist. Reverse Document No." := Rec."No."
                else
                    if DetailedGSTLedgerEntry."Dist. Reverse Document No." = Rec."No." then
                        DetailedGSTLedgerEntry."Dist. Reverse Document No." := '';
                DetailedGSTLedgerEntry.Modify();
            until TempDetailedGSTLedgerEntry.Next() = 0;
        end;

        DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", Rec."No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                DetailedGSTLedgerEntry2.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type");
                DetailedGSTLedgerEntry2.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                DetailedGSTLedgerEntry2.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
                DetailedGSTLedgerEntry2.SetRange("Dist. Reverse Document No.", '');
                if DetailedGSTLedgerEntry2.FindFirst() then
                    Error(
                      NoSelectErr,
                      DetailedGSTLedgerEntry.FieldCaption("Dist. Input GST Credit"),
                      DetailedGSTLedgerEntry."Document Type",
                      DetailedGSTLedgerEntry."Document No.",
                      DetailedGSTLedgerEntry."Document Line No.",
                      DetailedGSTLedgerEntry2."GST Component Code");
            until DetailedGSTLedgerEntry.Next() = 0;

        TempDetailedGSTLedgerEntry.DeleteAll();
        DetailedGSTLedgerEntry.SetRange("Dist. Document No.", Rec."Reversal Invoice No.");
        DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", Rec."No.");
        DetailedGSTLedgerEntry.SetRange(Distributed, true);
        DetailedGSTLedgerEntry.CalcSums("GST Amount");
        Rec."Total Amout Applied for Dist." := DetailedGSTLedgerEntry."GST Amount";
        Rec.Modify();

        GSTDistributionLine.Reset();
        GSTDistributionLine.SetRange("Distribution No.", Rec."No.");
        if GSTDistributionLine.FindSet() then
            repeat
                GSTDistributionLine.Validate("Distribution %");
                GSTDistributionLine.Modify(true);
            until GSTDistributionLine.Next() = 0;
    end;

    local procedure EnableFillBufferLine()
    begin
        ApplyBtnEnable := (Rec."From GSTIN No." <> '') and
          (Rec."Posting Date" <> 0D) and (Rec."Reversal Invoice No." <> '');
        CurrPage.UPDATE();
    end;

    var
        GSTDistribution: Codeunit "GST Distribution";
        ApplyBtnEnable: Boolean;
}
