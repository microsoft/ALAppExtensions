// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Sales.Customer;
using Microsoft.Service.History;
using System.IO;

codeunit 6159 "Pre-Map Service Cr. Memo Line"
{
    Access = Internal;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoLineFilters: Text;
        InStreamFilters: InStream;
        OutStreamFilters: OutStream;
        RoundingLineNo: Integer;
    begin
        RoundingLineNo := 0;
        Rec."Table Filters".CreateInStream(InStreamFilters);
        InStreamFilters.ReadText(ServiceCrMemoLineFilters);
        ServiceCrMemoLine.SetView(ServiceCrMemoLineFilters);
        ServiceCrMemoLine.SetFilter(Type, '<>%1', ServiceCrMemoLine.Type::" ");
        if ServiceCrMemoLine.FindSet() then
            repeat
                if IsRoundingLine(ServiceCrMemoLine) then
                    RoundingLineNo := ServiceCrMemoLine."Line No.";
            until ServiceCrMemoLine.Next() = 0;

        if RoundingLineNo <> 0 then
            ServiceCrMemoLine.SetFilter("Line No.", '<>%1', RoundingLineNo);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(ServiceCrMemoLine.GetView());
        Rec.Modify(true);
    end;

    local procedure IsRoundingLine(ServiceCrMemoLine: Record "Service Cr.Memo Line"): Boolean;
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if ServiceCrMemoLine.Type = ServiceCrMemoLine.Type::"G/L Account" then begin
            Customer.Get(ServiceCrMemoLine."Bill-to Customer No.");
            CustomerPostingGroup.SetFilter(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                if ServiceCrMemoLine."No." = CustomerPostingGroup."Invoice Rounding Account" then
                    exit(true);
        end;
        exit(false);
    end;
}