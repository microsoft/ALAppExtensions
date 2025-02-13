// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

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
        }
    }
}