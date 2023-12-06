// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Sales.Customer;
using Microsoft.Service.History;
using System.IO;

codeunit 6160 "Pre-Map Service Inv. Line"
{
    Access = Internal;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceInvLineFilters: Text;
        InStreamFilters: InStream;
        OutStreamFilters: OutStream;
        RoundingLineNo: Integer;
    begin
        RoundingLineNo := 0;
        Rec."Table Filters".CreateInStream(InStreamFilters);
        InStreamFilters.ReadText(ServiceInvLineFilters);
        ServiceInvoiceLine.SetView(ServiceInvLineFilters);
        ServiceInvoiceLine.SetFilter(Type, '<>%1', ServiceInvoiceLine.Type::" ");
        if ServiceInvoiceLine.FindSet() then
            repeat
                if IsRoundingLine(ServiceInvoiceLine) then
                    RoundingLineNo := ServiceInvoiceLine."Line No.";
            until ServiceInvoiceLine.Next() = 0;

        if RoundingLineNo <> 0 then
            ServiceInvoiceLine.SetFilter("Line No.", '<>%1', RoundingLineNo);

        Clear(Rec."Table Filters");
        Rec."Table Filters".CreateOutStream(OutStreamFilters);
        OutStreamFilters.WriteText(ServiceInvoiceLine.GetView());
        Rec.Modify(true);
    end;

    local procedure IsRoundingLine(ServiceInvoiceLine: Record "Service Invoice Line"): Boolean;
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if ServiceInvoiceLine.Type = ServiceInvoiceLine.Type::"G/L Account" then begin
            Customer.Get(ServiceInvoiceLine."Bill-to Customer No.");
            CustomerPostingGroup.SetFilter(Code, Customer."Customer Posting Group");
            if CustomerPostingGroup.FindFirst() then
                if ServiceInvoiceLine."No." = CustomerPostingGroup."Invoice Rounding Account" then
                    exit(true);
        end;
        exit(false);
    end;
}