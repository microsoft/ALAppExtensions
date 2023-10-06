// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.GST.Purchase;

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
