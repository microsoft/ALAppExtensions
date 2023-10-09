// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Application;

pageextension 18164 "GST Sales Invoice Stats." extends "Sales Statistics"
{
    layout
    {
        addlast(General)
        {
            field("GST Amount"; GSTAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount of GST that is included in the total amount.';
                Caption = 'GST Amount';
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
