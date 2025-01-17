// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TDS.TDSOnPurchase;

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
        addlast(Invoicing)
        {
            field("TDS Amt"; PartialInvTDSAmount)
            {
                Caption = 'TDS Amount';
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        addlast(Shipping)
        {
            field("TDS Purch Amt"; PartialRcptTDSAmount)
            {
                Caption = 'TDS Amount';
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
                ApplicationArea = Basic, Suite;
                Editable = false;
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
        TDSStatistics: Codeunit "TDS Statistics";
    begin
        TDSAmount := TDSStatsManagement.GetTDSStatsAmount();
        TDSStatistics.GetPartialPurchaseInvStatisticsAmount(Rec, PartialInvTDSAmount);
        TDSStatistics.GetPartialPurchaseRcptStatisticsAmount(Rec, PartialRcptTDSAmount);
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
        PartialInvTDSAmount: Decimal;
        PartialRcptTDSAmount: Decimal;
        Calculated: Boolean;
}
