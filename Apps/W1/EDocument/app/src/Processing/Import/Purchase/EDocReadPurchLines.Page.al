// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;

page 6184 "E-Doc. Read. Purch. Lines"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Received purchase document line data';
    SourceTable = "E-Document Purchase Line";
    SourceTableTemporary = true;
    Editable = false;
    Extensible = false;
    PageType = ListPart;

    layout
    {
        area(Content)
        {
            repeater(PurchaseLines)
            {
                field("Date"; Rec."Date")
                {
                    Caption = 'Date';
                    ToolTip = 'Specifies the date of this line.';
                }
                field("Product Code"; Rec."Product Code")
                {
                    Caption = 'Product Code';
                    ToolTip = 'Specifies the product code of this line.';
                }
                field("Description"; Rec."Description")
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of this line.';
                }
                field("Quantity"; Rec."Quantity")
                {
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the quantity of this line.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measure';
                    ToolTip = 'Specifies the unit of measure of this line.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency code of this line.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the unit price of this line.';
                }
                field("Sub Total"; Rec."Sub Total")
                {
                    Caption = 'Sub Total';
                    ToolTip = 'Specifies the sub total of this line.';
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    Caption = 'Total Discount';
                    ToolTip = 'Specifies the total discount of this line.';
                }
                field("VAT Rate"; Rec."VAT Rate")
                {
                    Caption = 'VAT Rate';
                    ToolTip = 'Specifies the VAT rate of this line.';
                }
            }
        }
    }

    internal procedure SetBuffer(var EDocumentPurchaseLine: Record "E-Document Purchase Line" temporary)
    begin
        Rec.DeleteAll();
        if EDocumentPurchaseLine.FindSet() then
            repeat
                Rec := EDocumentPurchaseLine;
                Rec.Insert();
            until EDocumentPurchaseLine.Next() = 0;
        if Rec.FindFirst() then;
    end;
}