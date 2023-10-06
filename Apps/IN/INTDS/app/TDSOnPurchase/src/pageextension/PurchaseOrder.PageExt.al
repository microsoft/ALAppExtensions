// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

pageextension 18722 "Purchase Order" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            field("Include GST in TDS Base"; Rec."Include GST in TDS Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this field to include GST value in the TDS Base.';

                trigger OnValidate()
                var
                    PurchaseLine: Record "Purchase Line";
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CurrPage.SaveRecord();
                    PurchaseLine.SetRange("Document Type", Rec."Document Type");
                    PurchaseLine.SetRange("Document No.", Rec."No.");
                    if PurchaseLine.FindSet() then
                        repeat
                            if PurchaseLine.Type <> PurchaseLine.Type::" " then
                                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
                        until PurchaseLine.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
