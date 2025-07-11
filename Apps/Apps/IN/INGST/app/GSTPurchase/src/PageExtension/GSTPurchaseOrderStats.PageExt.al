// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Purchase;
using Microsoft.Finance.GST.Base;

pageextension 18101 "GST Purchase Order Stats." extends "Purchase Order Statistics"
{
    layout
    {
        modify(InvDiscountAmount_General)
        {
            trigger OnAfterValidate()
            var
                GSTPurchaseSubscribers: Codeunit "GST Purchase Subscribers";
            begin
                GSTPurchaseSubscribers.ReCalculateGST(Rec."Document Type", Rec."No.");
            end;
        }
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
            field("Inv. GST Amt"; PartialRcptGSTAmount)
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
        GSTStatistics.OnGetPartialPurchaseHeaderGSTAmount(Rec, PartialInvGSTAmount);
        GSTStatistics.OnGetPartialPurchaseRcptGSTAmount(Rec, PartialRcptGSTAmount);
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
        PartialRcptGSTAmount: Decimal;
        Calculated: Boolean;
}
