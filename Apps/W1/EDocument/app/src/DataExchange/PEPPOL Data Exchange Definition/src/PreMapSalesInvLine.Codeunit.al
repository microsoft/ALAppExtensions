// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.IO;

codeunit 6158 "Pre-Map Sales Inv. Line"
{
    Access = Internal;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvLineFilters: Text;
        InStreamFilters: InStream;
        OutStreamFilters: OutStream;
        RoundingLineNo: Integer;
    begin
        RoundingLineNo := 0;
        Rec."Table Filters".CreateInStream(InStreamFilters);
        InStreamFilters.ReadText(SalesInvLineFilters);
        SalesInvoiceLine.SetView(SalesInvLineFilters);
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.FindSet() then
            repeat
                if IsRoundingLine(SalesInvoiceLine) then
                    RoundingLineNo := SalesInvoiceLine."Line No.";
            until SalesInvoiceLine.Next() = 0;

        if RoundingLineNo <> 0 then
            SalesInvoiceLine.SetFilter("Line No.", '<>%1', RoundingLineNo);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(SalesInvoiceLine.GetView());
        Rec.Modify(true);
    end;

    local procedure IsRoundingLine(SalesInvoiceLine: Record "Sales Invoice Line"): Boolean;
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if SalesInvoiceLine.Type = SalesInvoiceLine.Type::"G/L Account" then begin
            Customer.Get(SalesInvoiceLine."Bill-to Customer No.");
            CustomerPostingGroup.SetFilter(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                if SalesInvoiceLine."No." = CustomerPostingGroup."Invoice Rounding Account" then
                    exit(true);
        end;
        exit(false);
    end;
}