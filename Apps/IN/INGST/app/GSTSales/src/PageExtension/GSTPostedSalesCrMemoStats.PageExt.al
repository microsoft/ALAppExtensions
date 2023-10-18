// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Finance.GST.Application;

pageextension 18166 "GST Posted Sales Cr Memo Stats" extends "Sales Credit Memo Statistics"
{
    layout
    {
        addlast(General)
        {
            field("GST Amount"; GSTAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'GST Amount';
                ToolTip = 'Specifies the amount of GST that is included in the total amount.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetGSTAmount()
    var
        GSTStatsManagement: Codeunit "GST Stats Management";
    begin
        GSTAmount := GSTStatsManagement.GetGstStatsAmount();
        Calculated := true;
        GSTStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetGSTAmount();
    end;

    var

        GSTAmount: Decimal;
        Calculated: Boolean;
}
