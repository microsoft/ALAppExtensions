// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TaxBase;

tableextension 18838 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(18838; "Assessee Code"; code[10])
        {
            DataClassification = CustomerContent;
            editable = false;

            trigger Onvalidate()
            var
                SalesLine: Record "Sales Line";
            begin
                salesline.Reset();
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                if not salesline.IsEmpty() then
                    SalesLine.ModifyAll("Assessee Code", "Assessee Code");
            end;
        }
        field(18839; "Exclude GST in TCS Base"; Boolean)
        {
            Caption = 'Exclude GST in TCS Base';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                CalculateTax: Codeunit "Calculate Tax";
            begin
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                if SalesLine.FindSet() then
                    repeat
                        if SalesLine.Type <> SalesLine.Type::" " then
                            CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
                    until SalesLine.Next() = 0;
            end;
        }
    }
}
