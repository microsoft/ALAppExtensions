// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TCS.TCSOnSales;

pageextension 18839 "Sales Invoice Subform Ext" extends "Sales Invoice Subform"
{
    layout
    {
        addafter("Location Code")
        {
            field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the TCS Nature of collection on which the TCS will be calculated for the Sales Invoice.';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.AllowedNocLookup(Rec, Rec."Sell-to Customer No.");
                    UpdateTaxAmount();
                end;

                trigger OnValidate()
                var
                begin
                    UpdateTaxAmount();
                end;
            }
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            var
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Invoice Disc. Pct.")
        {
            trigger OnAfterValidate()
            begin
                TCSSalesManagement.UpdateTaxAmountOnSalesLine(Rec);
            end;
        }
        modify("Invoice Discount Amount")
        {
            trigger OnAfterValidate()
            begin
                TCSSalesManagement.UpdateTaxAmountOnSalesLine(Rec);
            end;
        }
    }
    local procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnSalesLine(Rec, xRec);
    end;

    var
        TCSSalesManagement: Codeunit "TCS Sales Management";
}
