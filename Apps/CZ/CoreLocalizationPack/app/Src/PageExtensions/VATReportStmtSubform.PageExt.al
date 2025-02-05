// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 31237 "VAT Report Stmt. Subform CZL" extends "VAT Report Statement Subform"
{
    layout
    {
        modify(Description)
        {
            trigger OnDrillDown()
            var
                VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
            begin
                VATStmtReportLineDataCZL.SetFilterTo(Rec);
                Page.RunModal(0, VATStmtReportLineDataCZL);
            end;
        }
        modify(Base)
        {
            Visible = false;
        }
        modify(Amount)
        {
            Visible = false;
        }
        addafter(Amount)
        {
            field("Base CZL"; Rec.CalcBase())
            {
                Caption = 'Base';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the amount that the VAT amount in the amount is calculated from.';
                Editable = false;
            }
            field("Amount CZL"; Rec.CalcAmount())
            {
                Caption = 'Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the amount of the entry in the report statement.';
                Editable = false;
            }
            field("Reduced Amount CZL"; Rec.CalcReducedAmount())
            {
                Caption = 'Reduced Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reduced amount of the entry in the report statement.';
                Editable = false;
            }
            field("Additional-Currency Base CZL"; Rec.CalcBaseAdditionalCurrency())
            {
                Caption = 'Additional-Currency Base';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Additional-Currency amount that the VAT amount in the amount is calculated from.';
                Editable = false;
                Visible = UseAmtsInAddCurrVisible;
            }
            field("Additional-Currency Amount CZL"; Rec.CalcAmountAdditionalCurrency())
            {
                Caption = 'Additional-Currency Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Additional-Currency amount of the entry in the report statement.';
                Editable = false;
                Visible = UseAmtsInAddCurrVisible;
            }
            field("Additional-Currency Reduced Amount CZL"; Rec.CalcReducedAmountAdditionalCurrency())
            {
                Caption = 'Additional-Currency Reduced Amount';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reduced Additional-Currency amount of the entry in the report statement.';
                Editable = false;
                Visible = UseAmtsInAddCurrVisible;
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
        UseAmtsInAddCurrVisible := (GeneralLedgerSetup."Additional Reporting Currency" <> '') and GeneralLedgerSetup."Functional Currency CZL";
    end;
}