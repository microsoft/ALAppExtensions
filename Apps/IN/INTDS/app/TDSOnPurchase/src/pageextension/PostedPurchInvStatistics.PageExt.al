// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.TDS.TDSBase;

pageextension 18716 "Posted Purch. Inv Statistics" extends "Purchase Invoice Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TDS Amount"; TDSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'TDS Amount';
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetTDSAmount()
    var
        TDSStatsManagement: Codeunit "TDS Stats Management";
    begin
        TDSAmount := TDSStatsManagement.GetTDSStatsAmount();
        Calculated := true;
        TDSStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTDSAmount();
    end;

    var

        TDSAmount: Decimal;
        Calculated: Boolean;
}
