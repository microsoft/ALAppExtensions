// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;

page 30172 "Shpfy Order Totals FactBox"
{
    ApplicationArea = All;
    Caption = 'Order Totals';
    PageType = CardPart;
    SourceTable = "Shpfy Order Header";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            group(Shopify)
            {
                Caption = 'Shopify';

                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify Order Number.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Shpfy Order", Rec);
                    end;
                }
                field("Subtotal Amount"; Rec."Subtotal Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the subtotal amount of the order.';
                }
                field("Shipping Charges Amount"; Rec."Shipping Charges Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the shipping charges amount of the order.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the total amount of the order.';
                }
                field(VATAmount; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalVATCaption(Rec."Currency Code");
                    ToolTip = 'Specifies the sum of tax amounts on all lines in the document.';
                }
                field(RoundingAmount; Rec."Payment Rounding Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the amount of rounding applied to the total amount of the document.';
                }
                field("VAT Included"; Rec."VAT Included")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if tax is included in the unit price.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
            }
            group(SalesDocument)
            {
                Caption = 'Sales Document';

                field(SalesDocumentNo; DocumentNo)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Document No.';
                    ToolTip = 'Specifies the sales document number.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Order", SalesHeader);
                    end;
                }
                field(TotalAmountExclVAT; TotalSalesLine.Amount)
                {
                    ApplicationArea = All;
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalExclVATCaption(CurrencyCode);
                    Caption = 'Total Amount Excl. VAT';
                    ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                }
                field("Total VAT Amount"; VATAmount)
                {
                    ApplicationArea = All;
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalVATCaption(CurrencyCode);
                    Caption = 'Total VAT';
                    ToolTip = 'Specifies the sum of VAT amounts on all lines in the document.';
                }
                field("Total Amount Incl. VAT"; TotalSalesLine."Amount Including VAT")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                    CaptionClass = DocumentTotals.GetTotalInclVATCaption(CurrencyCode);
                    Caption = 'Total Amount Incl. VAT';
                    ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document.';
                }
                field(PricesIncludingVAT; PricesIncludingVAT)
                {
                    ApplicationArea = All;
                    Caption = 'Prices Including VAT';
                    ToolTip = 'Specifies if tax is included in the unit price.';
                }
                field(NumberOfLines; NumberOfLines)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Lines';
                    ToolTip = 'Specifies the number of lines in the sales document.';

                    trigger OnDrillDown()
                    var
                        SalesLine: Record "Sales Line";
                    begin
                        SalesLine.SetRange("Document No.", DocumentNo);
                        Page.Run(Page::"Sales Lines", SalesLine);
                    end;
                }
                field(CurrencyCode; CurrencyCode)
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the currency of amounts on the sales document.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SalesLine: Record "Sales Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if Rec."Sales Order No." <> '' then
            SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Sales Order No.");

        if Rec."Sales Invoice No." <> '' then
            SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Sales Invoice No.");

        DocumentNo := SalesHeader."No.";
        PricesIncludingVAT := SalesHeader."Prices Including VAT";
        if CurrencyCode <> '' then
            CurrencyCode := SalesHeader."Currency Code"
        else begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        NumberOfLines := SalesLine.Count();
        if SalesLine.FindLast() then
            DocumentTotals.CalculateSalesTotals(TotalSalesLine, VATAmount, SalesLine);
    end;

    var
        SalesHeader: Record "Sales Header";
        TotalSalesLine: Record "Sales Line";
        DocumentTotals: Codeunit "Document Totals";
        DocumentNo: Text[20];
        PricesIncludingVAT: Boolean;
        NumberOfLines: Integer;
        CurrencyCode: Code[10];
        VATAmount: Decimal;
}