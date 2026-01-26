// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Customer;

tableextension 31063 "Job Task CZZ" extends "Job Task"
{
    trigger OnAfterDelete()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if (Rec.IsTemporary) or (Rec."Job No." = '') or (Rec."Job Task No." = '') then
            exit;

        SalesAdvLetterHeaderCZZ.SetRange("Job No.", Rec."Job No.");
        SalesAdvLetterHeaderCZZ.SetRange("Job Task No.", Rec."Job Task No.");
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                SalesAdvLetterHeaderCZZ."Job No." := '';
                SalesAdvLetterHeaderCZZ."Job Task No." := '';
                SalesAdvLetterHeaderCZZ.Modify();
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    var
        Customer: Record Customer;
        Job: Record Job;

    internal procedure GetBillToCustomerNo(): Code[20]
    begin
        if "Bill-to Customer No." <> '' then
            exit("Bill-to Customer No.");
        exit(GetJob()."Bill-to Customer No.");
    end;

    internal procedure GetVATBusPostingGroup(): Code[20]
    begin
        exit(GetBillToCustomer()."VAT Bus. Posting Group");
    end;

    internal procedure GetCurrencyCode(): Code[10]
    begin
        exit(GetJob()."Currency Code");
    end;

    local procedure GetJob(): Record Job
    begin
        if ("Job No." <> Job."No.") and ("Job No." <> '') then
            if not Job.Get("Job No.") then
                Job.Init();
        exit(Job);
    end;

    internal procedure GetBillToCustomer(): Record Customer
    var
        CustomerNo: Code[20];
    begin
        CustomerNo := GetBillToCustomerNo();
        if (CustomerNo <> Customer."No.") and (CustomerNo <> '') then
            if not Customer.Get(CustomerNo) then
                Customer.Init();
        exit(Customer);
    end;
}