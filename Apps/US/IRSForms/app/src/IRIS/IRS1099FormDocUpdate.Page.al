// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10067 "IRS 1099 Form Doc. Update"
{
    PageType = ListPlus;
    ApplicationArea = BasicUS;
    Caption = 'Update 1099 Form Documents';
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Line Action");
    SourceTable = "IRS 1099 Form Doc. Line";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            label(UpdateInstruction)
            {
                Caption = 'Select the Process Line check box for the 1099 forms for which you want to recalculate the Amount and Calculated Amount from the current vendor ledger entries OR to create new 1099 form documents based on the current vendor ledger entries.';
                Style = StandardAccent;
            }
            repeater(General)
            {
#pragma warning disable AA0219
                field("Process Line"; Rec."Process Line")
                {
                    Caption = 'Process Line';
                    ToolTip = 'Select this check box to update the Amount and Calculated Amount of the existing 1099 form document line or to create a new 1099 form document based on the current vendor ledger entries.';
                    Visible = true;
                }
#pragma warning restore AA0219
                field("Line Action"; Rec."Line Action")
                {
                    ToolTip = 'Specifies the action to be performed on the 1099 form document line.';
                    Style = Favorable;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the vendor number to which the 1099 form document line belongs.';
                    Editable = false;
                }
                field("Form No."; Rec."Form No.")
                {
                    ToolTip = 'Specifies the form type of the 1099 form document line.';
                    Visible = false;
                }
                field("Form Box No."; Rec."Form Box No.")
                {
                    ToolTip = 'Specifies the form box number of the 1099 form document line.';
                    Editable = false;
                }
                field(CurrentAmount; CurrAmount)
                {
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                    Caption = 'Current Amount';
                    ToolTip = 'Specifies the amount that was calculated from the vendor ledger entries when the 1099 form document was created.';
                    Editable = false;
                }
                field(NewAmount; Rec.Amount)
                {
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                    Caption = 'New Amount';
                    ToolTip = 'Specifies the amount that is calculated from the current vendor ledger entries.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                    Tooltip = 'Specifies the calculated adjustment amount of the document line. It is set using the Adjustments action of the IRS Reporting Periods page.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
    begin
        if IRS1099FormDocLine.Get(Rec."Period No.", Rec."Vendor No.", Rec."Form No.", Rec."Document ID", Rec."Line No.") then
            CurrAmount := IRS1099FormDocLine.Amount;
    end;

    var
        CurrAmount: Decimal;

    internal procedure SetLines(var TempIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line" temporary)
    begin
        if TempIRS1099FormDocLine.FindSet() then
            repeat
                Rec := TempIRS1099FormDocLine;
                Rec.Insert();
            until TempIRS1099FormDocLine.Next() = 0;
    end;

    internal procedure GetSelectedLines(var TempIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line" temporary)
    begin
        TempIRS1099FormDocLine.Reset();
        TempIRS1099FormDocLine.DeleteAll();

        Rec.SetRange("Process Line", true);
        if Rec.FindSet() then
            repeat
                TempIRS1099FormDocLine := Rec;
                TempIRS1099FormDocLine.Insert();
            until Rec.Next() = 0;
    end;
}