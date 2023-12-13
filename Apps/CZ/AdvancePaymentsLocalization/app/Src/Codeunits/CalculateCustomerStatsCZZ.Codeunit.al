// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Customer;

codeunit 31412 "Calculate Customer Stats. CZZ"
{
    trigger OnRun()
    var
        Customer: record Customer;
        Params: Dictionary of [Text, Text];
        Results: Dictionary of [Text, Text];
        CustomerNo: Code[20];
    begin
        Params := Page.GetBackgroundParameters();
        CustomerNo := CopyStr(Params.Get(GetCustomerNoLabel()), 1, MaxStrLen(CustomerNo));
        if not Customer.Get(CustomerNo) then
            exit;

        Results.Add(GetAdvancesLabel(), Format(Customer.GetSalesAdvancesCountCZZ()));

        Page.SetBackgroundTaskResult(Results);
    end;

    var
        CustomerNoLbl: label 'Customer No.', Locked = true;
        LastAdvancesLbl: label 'Advances', Locked = true;

    internal procedure GetCustomerNoLabel(): Text
    begin
        exit(CustomerNoLbl);
    end;

    internal procedure GetAdvancesLabel(): Text
    begin
        exit(LastAdvancesLbl);
    end;
}
