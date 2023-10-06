// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

tableextension 18717 "Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(18716; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
                CalculateTax: Codeunit "Calculate Tax";
            begin
                PurchLine.Reset();
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                if PurchLine.FindSet() then
                    repeat
                        if PurchLine.Type <> PurchLine.Type::" " then
                            CalculateTax.CallTaxEngineOnPurchaseLine(PurchLine, PurchLine);
                    until PurchLine.Next() = 0;
            end;
        }
    }
}
