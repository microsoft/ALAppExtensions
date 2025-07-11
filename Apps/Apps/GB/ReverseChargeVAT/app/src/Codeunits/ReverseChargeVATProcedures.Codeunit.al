// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Document;

codeunit 10557 "Reverse Charge VAT Procedures"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure CheckIfReverseChargeApplies(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        TotalAmount: Decimal;
    begin
        GLSetup.Get();
        SalesSetup.Get();
        if not GLSetup."Threshold applies GB" or (SalesHeader."VAT Registration No." = '') or
           (SalesSetup."Domestic Customers GB" <> SalesHeader."VAT Bus. Posting Group")
        then
            exit(false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Reverse Charge Item GB", true);
        SalesLine.SetFilter(Quantity, '<>0');
        SalesLine.SetFilter("Qty. to Invoice", '<>0');
        if SalesLine.FindSet() then
            repeat
                TotalAmount := TotalAmount + SalesLine.Amount * SalesLine."Qty. to Invoice" / SalesLine.Quantity;
                if SalesHeader."Currency Factor" <> 0 then begin
                    if TotalAmount - SalesLine."Inv. Discount Amount" >= GLSetup."Threshold Amount GB" * SalesHeader."Currency Factor" then
                        exit(true);
                end else
                    if TotalAmount - SalesLine."Inv. Discount Amount" >= GLSetup."Threshold Amount GB" then
                        exit(true);
            until SalesLine.Next() = 0;
        exit(false);
    end;
}