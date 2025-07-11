// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSForCustomer;

pageextension 18667 "Cash Receipt Journal TDS" extends "Cash Receipt Journal"
{
    layout
    {
        addbefore(Amount)
        {
            field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TDS Certificate Receivable';
                ToolTip = 'Selected to allow calculating TDS for the customer.';
            }
            field("TDS Section Code"; Rec."TDS Section Code")
            {
                Visible = false;
                ApplicationArea = Basic, Suite;
                Caption = 'TDS Section Code';
                ToolTip = 'Specifies the Section Codes as per the Income Tax Act 1961 for e tds returns';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    TDSForCustomerSubscribers: Codeunit "TDS For Customer Subscribers";
                begin
                    TDSForCustomerSubscribers.TDSSectionCodeLookupGenLineForCustomer(Rec, Rec."Account No.", true);
                    UpdateTaxAmount();
                end;
            }
        }
    }
    local procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;
}
