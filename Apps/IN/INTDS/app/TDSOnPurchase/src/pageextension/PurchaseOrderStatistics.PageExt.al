// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TDS.TDSBase;

pageextension 18719 "Purchase Order Statistics" extends "Purchase Order Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TDS Amount"; TDSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
                Caption = 'TDS Amount';
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
