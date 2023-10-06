// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.TCS.TCSOnSales;

pageextension 18842 "Sales Order Statistics" extends "Sales Order Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TCS Amount"; TCSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the total TCS amount that has been calculated for all the lines in the sales document.';
                Caption = 'TCS Amount';
            }
        }
        modify(InvDiscountAmount_General)
        {
            trigger OnAfterValidate()
            var
                TCSSalesManagement: Codeunit "TCS Sales Management";
            begin
                TCSSalesManagement.UpdateTaxAmount(Rec);
            end;
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetTCSAmount()
    var
        TCSStatsManagement: Codeunit "TCS Stats Management";
    begin
        TCSAmount := TCSStatsManagement.GetTCSStatsAmount();
        Calculated := true;
        TCSStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTCSAmount();
    end;

    var
        TCSAmount: Decimal;
        Calculated: Boolean;
}
