// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;

page 31217 "VAT Stmt. Report Line Data CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Statement Report Line Data CZL';
    Editable = false;
    PageType = List;
    SourceTable = "VAT Stmt. Report Line Data CZL";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Row No."; Rec."Row No.")
                {
                    ToolTip = 'Specifies the row number of the statement.';
                }
                field("Description"; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the statement.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount of the statement.';
                }
                field("Additional-Currency Amount"; Rec."Additional-Currency Amount")
                {
                    ToolTip = 'Specifies the amount of the statement in additional currency.';
                    Visible = UseAmtsInAddCurrVisible;
                }
                field("VAT Report Amount Type"; Rec."VAT Report Amount Type")
                {
                    ToolTip = 'Specifies the attribute code value to display amounts in corresponding columns of VAT Return.';
                    Visible = false;
                }
            }
        }
    }
    var
        UseAmtsInAddCurrVisible: Boolean;

    trigger OnOpenPage()
    begin
        SetUseAmtsInAddCurrVisible()
    end;

    local procedure SetUseAmtsInAddCurrVisible()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        UseAmtsInAddCurrVisible := (GeneralLedgerSetup."Additional Reporting Currency" <> '') and (GeneralLedgerSetup."Functional Currency CZL");
    end;
}