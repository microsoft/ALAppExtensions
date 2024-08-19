// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Projects.Project.Job;
using Microsoft.Sales.Customer;

tableextension 31064 "Job CZZ" extends "Job"
{
    trigger OnAfterDelete()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if (Rec.IsTemporary) or (Rec."No." = '') then
            exit;

        SalesAdvLetterHeaderCZZ.SetRange("Job No.", Rec."No.");
        SalesAdvLetterHeaderCZZ.ModifyAll("Job No.", '');
    end;

    var
        Customer: Record Customer;

    internal procedure GetBillToCustomer(): Record Customer
    begin
        if ("Bill-to Customer No." <> Customer."No.") and ("Bill-to Customer No." <> '') then
            Customer.Get("Bill-to Customer No.");
        exit(Customer);
    end;
}