// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;

page 18203 "GST Distribution"
{
    Caption = 'GST Distribution';
    PageType = Document;
    SourceTable = "GST Distribution Header";
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

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
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("ISD Document Type"; Rec."ISD Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'ISD Document Type';
                    ToolTip = 'Specifies the document type an identifier Invoices.';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'From Location Code';
                    ToolTip = 'Specifies location code from which input will be distributed, input service distribution field need to be marked true for this location.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'From GSTIN No.';
                    ToolTip = 'Specifies from which GSTIN No. input credit will be distributed.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the entry''s Posting Date.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Dist. Document Type"; Rec."Dist. Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dist. Document Type';
                    ToolTip = 'Specifies the document type as an identifier for distribution.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Dist. Credit Type"; Rec."Dist. Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dist. Credit Type';
                    ToolTip = 'Specifies if the distribution credit to be availed or not.';

                    trigger OnValidate()
                    begin
                        EnableFillBufferLine();
                    end;
                }
                field("Total Amout Applied for Dist."; Rec."Total Amout Applied for Dist.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Amout Applied for Dist.';
                    Editable = false;
                    ToolTip = 'Specifies the total amount to be applied for distribution on the basis of apply invoice.';
                }
                field("Distribution Basis"; Rec."Distribution Basis")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribution Basis';
                    ToolTip = 'Specifies the distribution basis for application.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension code 1 defined in general ledger setup.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension code 2 defined in general ledger setup.';
                }
            }
            part(Subform; "GST Distribution Lines")
            {
                SubPageLink = "Distribution No." = field("No.");
                ApplicationArea = Basic, Suite;
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
                    Image = Dimensions;
                    Promoted = false;
                    ApplicationArea = Basic, Suite;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Specifies the process to view or edit dimentions, that can be assigned to transactions to distribute cost and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SAVERECORD();
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
                    Enabled = ApplyBtnEnable;
                    Image = ApplyEntries;
                    ShortCutKey = 'Shift+F11';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Apply the amount on journal line to the relevant posted entry, this updated the posted document.';

                    trigger OnAction()
                    begin
                        ApplyEntries();
                    end;
                }
                action(Post)
                {
                    Caption = 'Post';
                    Image = ApplyEntries;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Finalize the document or journal by posting the amounts to the related accounts in your company books.';
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        GSTDistributionMsg: Label 'Distribution Lines Posted successfully.';
                    begin
                        GSTDistribution.InsertDistComponentAmount(Rec."No.", false);
                        if GSTDistribution.PostGSTDistribution(Rec."No.", '', false) then begin
                            Message(GSTDistributionMsg);
                            CurrPage.Close();
                        end;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EnableFillBufferLine();
    end;

    var
        GSTDistribution: Codeunit "GST Distribution";
        ApplyBtnEnable: Boolean;

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
        if Rec."Dist. Document Type" = Rec."Dist. Document Type"::Invoice then
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice)
        else
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry.SetRange("Location  Reg. No.", Rec."From GSTIN No.");
        DetailedGSTLedgerEntry.SetRange(Type, DetailedGSTLedgerEntry.Type::"G/L Account");
        if Rec."Dist. Credit Type" = Rec."Dist. Credit Type"::Availment then
            DetailedGSTLedgerEntry.SetRange("GST Credit", DetailedGSTLedgerEntry."GST Credit"::Availment)
        else
            DetailedGSTLedgerEntry.SetRange("GST Credit", DetailedGSTLedgerEntry."GST Credit"::"Non-Availment");
        DetailedGSTLedgerEntry.SetRange("Posting Date", 0D, Rec."Posting Date");
        DetailedGSTLedgerEntry.SetRange("Input Service Distribution", true);
        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        DetailedGSTLedgerEntry.SetRange(Distributed, false);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if not ((DetailedGSTLedgerEntry."ARN No." <> '') and (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '')) then begin
                    TempDetailedGSTLedgerEntry := DetailedGSTLedgerEntry;
                    if DetailedGSTLedgerEntry."Dist. Document No." = Rec."No." then
                        TempDetailedGSTLedgerEntry."Dist. Input GST Credit" := true;
                    TempDetailedGSTLedgerEntry.Insert();
                end;
            until DetailedGSTLedgerEntry.Next() = 0;

        if Page.RunModal(Page::"Dist. Input GST Credit", TempDetailedGSTLedgerEntry) = Action::LookupOK then begin
            TempDetailedGSTLedgerEntry.FindSet();
            repeat
                DetailedGSTLedgerEntry.Get(TempDetailedGSTLedgerEntry."Entry No.");
                if TempDetailedGSTLedgerEntry."Dist. Input GST Credit" then
                    DetailedGSTLedgerEntry."Dist. Document No." := Rec."No."
                else
                    if DetailedGSTLedgerEntry."Dist. Document No." = Rec."No." then
                        DetailedGSTLedgerEntry."Dist. Document No." := '';
                DetailedGSTLedgerEntry.Modify();
            until TempDetailedGSTLedgerEntry.Next() = 0;
        end;

        DetailedGSTLedgerEntry.SetRange("Dist. Document No.", Rec."No.");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                DetailedGSTLedgerEntry2.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type");
                DetailedGSTLedgerEntry2.SetRange("Document No.", DetailedGSTLedgerEntry."Document No.");
                DetailedGSTLedgerEntry2.SetRange("Document Line No.", DetailedGSTLedgerEntry."Document Line No.");
                DetailedGSTLedgerEntry2.SetRange("Dist. Document No.", '');
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
        DetailedGSTLedgerEntry.SetRange("Dist. Document No.", Rec."No.");
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
        ApplyBtnEnable :=
          (Rec."From Location Code" <> '') and (Rec."Posting Date" <> 0D) and
          (Rec."Dist. Document Type" <> Rec."Dist. Document Type"::" ");
        CurrPage.Update();
    end;
}
