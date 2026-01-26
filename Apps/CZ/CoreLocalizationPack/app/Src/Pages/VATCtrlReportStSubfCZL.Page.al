// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.GeneralLedger.Setup;

page 31114 "VAT Ctrl. Report St. Subf. CZL"
{
    Caption = 'Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "VAT Ctrl. Report Buffer CZL";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("VAT Ctrl. Report Section Code"; Rec."VAT Ctrl. Report Section Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the section code for the VAT Control Report.';
                }
                field("VAT Control Rep. Section Desc."; Rec."VAT Control Rep. Section Desc.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the section code for the VAT Control Report.';
                }
                field("Base 1"; Rec."Base 1")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total base amount for the base VAT.';
                }
                field("Base 2"; Rec."Base 2")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total base amount for the reduced VAT.';
                }
                field("<Base 3>"; Rec."Base 3")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total base amount for the reduced 2 VAT.';
                }
                field("Amount 1"; Rec."Amount 1")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount for the base VAT.';
                }
                field("Amount 2"; Rec."Amount 2")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount for the reduced VAT.';
                }
                field("Amount 3"; Rec."Amount 3")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount for the reduced 2 VAT.';
                }
                field("Total Base"; Rec."Total Base")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the Total Amount of all VAT Base for selected VAT Ctrl. Report statement Section';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the Total Amount of all VAT for selected VAT Ctrl. Report statement Section';
                }
                field("Add.-Currency Base 1"; Rec."Add.-Currency Base 1")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency base amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Base 2"; Rec."Add.-Currency Base 2")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency base amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Base 3"; Rec."Add.-Currency Base 3")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency base amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Amount 1"; Rec."Add.-Currency Amount 1")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Amount 2"; Rec."Add.-Currency Amount 2")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Amount 3"; Rec."Add.-Currency Amount 3")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    ToolTip = 'Specifies the total additional currency amount for the base VAT.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Total Base"; Rec."Add.-Currency Total Base")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total additional currency amount of all VAT Base for selected VAT Ctrl. Report statement Section';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("Add.-Currency Total Amount"; Rec."Add.-Currency Total Amount")
                {
                    ApplicationArea = VAT;
                    BlankZero = true;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total additional currency amount of all VAT for selected VAT Ctrl. Report statement Section';
                    Visible = UseAmtsInAddCurrVisible;
                }
            }
        }
    }
    var
        UseAmtsInAddCurrVisible: Boolean;

    trigger OnOpenPage()
    begin
        SetUseAmtsInAddCurrVisible();
    end;

    procedure SetTempVATCtrlRepBuffer(var NewVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL")
    begin
        Rec.DeleteAll();
        if NewVATCtrlReportBufferCZL.FindSet() then
            repeat
                Rec.Copy(NewVATCtrlReportBufferCZL);
                Rec.Insert();
            until NewVATCtrlReportBufferCZL.Next() = 0;
        CurrPage.Update(false);
    end;

    local procedure SetUseAmtsInAddCurrVisible()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        UseAmtsInAddCurrVisible := GeneralLedgerSetup."Additional Reporting Currency" <> '';
    end;
}
