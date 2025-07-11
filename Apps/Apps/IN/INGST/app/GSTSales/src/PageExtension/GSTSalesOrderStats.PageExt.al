// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Base;

pageextension 18163 "GST Sales Order Stats." extends "Sales Order Statistics"
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
        addlast(Invoicing)
        {
            field("Inv. GST Amount"; PartialInvGSTAmount)
            {
                Caption = 'GST Amount';
                ToolTip = 'Specifies the amount of GST that is partial amount of total.';
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        addlast(Shipping)
        {
            field("Inv. GST Amt"; PartialShptGSTAmount)
            {
                Caption = 'GST Amount';
                ToolTip = 'Specifies the amount of GST that is partial amount of total.';
                ApplicationArea = Basic, Suite;
                Editable = false;
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
        GSTStatistics: Codeunit "GST Statistics";
    begin
        GSTAmount := GSTStatsManagement.GetGstStatsAmount();
        GSTStatistics.GetPartialSalesStatisticsAmount(Rec, PartialInvGSTAmount);
        GSTStatistics.GetPartialSalesShptStatisticsAmount(Rec, PartialShptGSTAmount);
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
        PartialInvGSTAmount: Decimal;
        PartialShptGSTAmount: Decimal;
        Calculated: Boolean;
}
