// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using System.IO;

codeunit 6157 "Pre-Map Sales Cr. Memo Line"
{
    Access = Internal;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoLineFilters: Text;
        InStreamFilters: InStream;
        OutStreamFilters: OutStream;
        RoundingLineNo: Integer;
    begin
        RoundingLineNo := 0;
        Rec."Table Filters".CreateInStream(InStreamFilters);
        InStreamFilters.ReadText(SalesCrMemoLineFilters);
        SalesCrMemoLine.SetView(SalesCrMemoLineFilters);
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        if SalesCrMemoLine.FindSet() then
            repeat
                if IsRoundingLine(SalesCrMemoLine) then
                    RoundingLineNo := SalesCrMemoLine."Line No.";
            until SalesCrMemoLine.Next() = 0;

        if RoundingLineNo <> 0 then
            SalesCrMemoLine.SetFilter("Line No.", '<>%1', RoundingLineNo);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(SalesCrMemoLine.GetView());
        Rec.Modify(true);
    end;

    local procedure IsRoundingLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"): Boolean;
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if SalesCrMemoLine.Type = SalesCrMemoLine.Type::"G/L Account" then begin
            Customer.Get(SalesCrMemoLine."Bill-to Customer No.");
            CustomerPostingGroup.SetFilter(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                if SalesCrMemoLine."No." = CustomerPostingGroup."Invoice Rounding Account" then
                    exit(true);
        end;
        exit(false);
    end;
}