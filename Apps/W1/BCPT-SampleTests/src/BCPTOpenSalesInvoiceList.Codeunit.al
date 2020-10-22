// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149114 "BCPT Open Sales Invoice List"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenSalesInvoiceList()
    var
        SalesInvoiceList: testpage "Sales Invoice List";
    begin
        SalesInvoiceList.OpenView();
        SalesInvoiceList.Close();
    end;
}