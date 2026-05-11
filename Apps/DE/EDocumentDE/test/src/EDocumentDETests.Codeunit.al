// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;
using Microsoft.Service.Test;

codeunit 13923 "E-Document DE Tests"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun();
    begin
        // [FEATURE] [E-Document DE]
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryEDocDE: Codeunit "Library - E-Doc DE";
        Assert: Codeunit Assert;

    #region BuyerReference

    [Test]
    procedure SalesHeaderBuyerReferenceFromCustomerWithRoutingNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        RoutingNo: Text[100];
    begin
        // [SCENARIO] When creating a Sales Invoice for a customer with E-Invoice Routing No., the Buyer Reference is set from the customer.

        // [GIVEN] Customer with E-Invoice Routing No.
        RoutingNo := LibraryEDocDE.CreateValidRoutingNo();
        CreateCustomerWithRoutingNo(Customer, RoutingNo);

        // [WHEN] Create Sales Invoice for the customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [THEN] Buyer Reference is set to the customer's E-Invoice Routing No.
        Assert.AreEqual(RoutingNo, SalesHeader."Buyer Reference", 'Buyer Reference should be set from Customer E-Invoice Routing No.');
    end;

    [Test]
    procedure SalesHeaderBuyerReferenceBlankWhenCustomerHasNoRoutingNo()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] When creating a Sales Invoice for a customer without E-Invoice Routing No., the Buyer Reference is blank.

        // [GIVEN] Customer without E-Invoice Routing No.
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Create Sales Invoice for the customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        // [THEN] Buyer Reference is blank
        Assert.AreEqual('', SalesHeader."Buyer Reference", 'Buyer Reference should be blank when customer has no E-Invoice Routing No.');
    end;

    [Test]
    procedure SalesHeaderBuyerReferenceUpdatesOnBillToChange()
    var
        Customer1: Record Customer;
        Customer2: Record Customer;
        SalesHeader: Record "Sales Header";
        RoutingNo1: Text[100];
        RoutingNo2: Text[100];
    begin
        // [SCENARIO] When changing the Bill-to Customer on a Sales Invoice, the Buyer Reference updates to the new customer's E-Invoice Routing No.

        // [GIVEN] Two customers with different E-Invoice Routing No. values
        RoutingNo1 := LibraryEDocDE.CreateValidRoutingNo();
        RoutingNo2 := LibraryEDocDE.CreateValidRoutingNo();
        CreateCustomerWithRoutingNo(Customer1, RoutingNo1);
        CreateCustomerWithRoutingNo(Customer2, RoutingNo2);

        // [GIVEN] Sales Invoice for Customer 1
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer1."No.");
        Assert.AreEqual(RoutingNo1, SalesHeader."Buyer Reference", 'Initial Buyer Reference should be from Customer 1.');

        // [WHEN] Change Bill-to Customer to Customer 2
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Bill-to Customer No.", Customer2."No.");

        // [THEN] Buyer Reference is updated to Customer 2's E-Invoice Routing No.
        Assert.AreEqual(RoutingNo2, SalesHeader."Buyer Reference", 'Buyer Reference should update to Customer 2 E-Invoice Routing No.');
    end;

    [Test]
    procedure ServiceHeaderBuyerReferenceFromCustomerWithRoutingNo()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        RoutingNo: Text[100];
    begin
        // [SCENARIO] When creating a Service Invoice for a customer with E-Invoice Routing No., the Buyer Reference is set from the customer.

        // [GIVEN] Customer with E-Invoice Routing No.
        RoutingNo := LibraryEDocDE.CreateValidRoutingNo();
        CreateCustomerWithRoutingNo(Customer, RoutingNo);

        // [WHEN] Create Service Invoice for the customer
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, Customer."No.");

        // [THEN] Buyer Reference is set to the customer's E-Invoice Routing No.
        Assert.AreEqual(RoutingNo, ServiceHeader."Buyer Reference", 'Buyer Reference should be set from Customer E-Invoice Routing No.');
    end;

    [Test]
    procedure ServiceHeaderBuyerReferenceBlankWhenCustomerHasNoRoutingNo()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
    begin
        // [SCENARIO] When creating a Service Invoice for a customer without E-Invoice Routing No., the Buyer Reference is blank.

        // [GIVEN] Customer without E-Invoice Routing No.
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Create Service Invoice for the customer
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, Customer."No.");

        // [THEN] Buyer Reference is blank
        Assert.AreEqual('', ServiceHeader."Buyer Reference", 'Buyer Reference should be blank when customer has no E-Invoice Routing No.');
    end;

    [Test]
    procedure ServiceHeaderBuyerReferenceUpdatesOnBillToChange()
    var
        Customer1: Record Customer;
        Customer2: Record Customer;
        ServiceHeader: Record "Service Header";
        RoutingNo1: Text[100];
        RoutingNo2: Text[100];
    begin
        // [SCENARIO] When changing the Bill-to Customer on a Service Invoice, the Buyer Reference updates to the new customer's E-Invoice Routing No.

        // [GIVEN] Two customers with different E-Invoice Routing No. values
        RoutingNo1 := LibraryEDocDE.CreateValidRoutingNo();
        RoutingNo2 := LibraryEDocDE.CreateValidRoutingNo();
        CreateCustomerWithRoutingNo(Customer1, RoutingNo1);
        CreateCustomerWithRoutingNo(Customer2, RoutingNo2);

        // [GIVEN] Service Invoice for Customer 1
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, Customer1."No.");
        Assert.AreEqual(RoutingNo1, ServiceHeader."Buyer Reference", 'Initial Buyer Reference should be from Customer 1.');

        // [WHEN] Change Bill-to Customer to Customer 2
        ServiceHeader.SetHideValidationDialog(true);
        ServiceHeader.Validate("Bill-to Customer No.", Customer2."No.");

        // [THEN] Buyer Reference is updated to Customer 2's E-Invoice Routing No.
        Assert.AreEqual(RoutingNo2, ServiceHeader."Buyer Reference", 'Buyer Reference should update to Customer 2 E-Invoice Routing No.');
    end;

    #endregion

    local procedure CreateCustomerWithRoutingNo(var Customer: Record Customer; RoutingNo: Text[100])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."E-Invoice Routing No." := RoutingNo;
        Customer.Modify(true);
    end;
}
