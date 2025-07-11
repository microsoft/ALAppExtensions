// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

pageextension 18718 "PurchaseInvoiceSubform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("TDS Section Code"; Rec."TDS Section Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Section Codes as per the Income Tax Act 1961 for e tds returns';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.OnAfterTDSSectionCodeLookupPurchLine(Rec, Rec."Buy-from Vendor No.", true);
                    UpdateTaxAmount();
                end;

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("Nature of Remittance"; Rec."Nature of Remittance")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the type of remittance deductee deals with.';
                trigger OnValidate()
                begin
                    Rec.CheckNonResidentsPaymentSelection();
                    UpdateTaxAmount()
                end;
            }
            field("Act Applicable"; Rec."Act Applicable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the tax rates prescribed under the IT Act or DATA on the TDS entry.';
                trigger OnValidate()
                begin
                    Rec.CheckNonResidentsPaymentSelection();
                    UpdateTaxAmount()
                end;
            }
        }
    }
    local procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
    end;
}
