// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;

codeunit 134246 "Shpfy Tax Id Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestGetTaxRegistrationIdForRegistrationNo()
    var
        Customer: Record Customer;
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        RegistrationNo: Text[50];
        RegistrationNoResult: Text[150];
    begin
        // [SCENARIO] GetTaxRegistrationId for Tax Registration No. implementation of mapping
        Initialize();

        // [GIVEN] Registration No.
        RegistrationNo := CopyStr(Any.AlphanumericText(50), 1, MaxStrLen(RegistrationNo));
        // [GIVEN] Customer
        CreateCustomerWithRegistrationNo(Customer, RegistrationNo);
        // [GIVEN] TaxRegistrationIdMapping interface is "Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.";

        // [WHEN] GetTaxRegistrationId is called
        RegistrationNoResult := TaxRegistrationIdMapping.GetTaxRegistrationId(Customer);

        // [THEN] The result is the same as the Registration No. field of the Customer record
        LibraryAssert.AreEqual(RegistrationNo, RegistrationNoResult, 'Registration No.');
    end;

    [Test]
    procedure UnitTestGetTaxRegistrationIdForVATRegistrationNo()
    var
        Customer: Record Customer;
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        VATRegistrationNo: Text[20];
        VATRegistrationNoResult: Text[150];
    begin
        // [SCENARIO] GetTaxRegistrationId for VAT Registration No. implementation of mapping
        Initialize();

        // [GIVEN] VAT Registration No.
        VATRegistrationNo := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(VATRegistrationNo));
        // [GIVEN] Customer
        CreateCustomerWithVATRegNo(Customer, VATRegistrationNo);
        // [GIVEN] TaxRegistrationIdMapping interface is "VAT Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"VAT Registration No.";

        // [WHEN] GetTaxRegistrationId is called
        VATRegistrationNoResult := TaxRegistrationIdMapping.GetTaxRegistrationId(Customer);

        // [THEN] The result is the same as the VAT Registration No. field of the Customer record
        LibraryAssert.AreEqual(VATRegistrationNo, VATRegistrationNoResult, 'VAT Registration No.');
    end;

    [Test]
    procedure UnitTestSetMappingFiltersForCustomersWithRegistrationNo()
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        RegistrationNo: Text[50];
    begin
        // [SCENARIO] SetMappingFiltersForCustomers for Tax Registration Id implementation of mapping
        Initialize();

        // [GIVEN] Registration No. 
        RegistrationNo := CopyStr(Any.AlphanumericText(50), 1, MaxStrLen(RegistrationNo));
        // [GIVEN] Customer record with Registration No.
        CreateCustomerWithRegistrationNo(Customer, RegistrationNo);
        // [GIVEN] CompanyLocation record with Tax Registration Id
        CreateLocationWithTaxId(CompanyLocation, RegistrationNo);
        // [GIVEN] TaxRegistrationIdMapping interface is "Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.";

        // [WHEN] SetMappingFiltersForCustomers is called
        TaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);

        // [THEN] The range of the Customer record is set to the Tax Registration Id of the CompanyLocation record
        LibraryAssert.AreEqual(RegistrationNo, Customer.GetFilter("Registration Number"), 'Registration No. filter is not set correctly.');
    end;

    [Test]
    procedure UnitTestSetMappingFiltersForCustomersWithVATRegistrationNo()
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        VATRegistrationNo: Text[50];
    begin
        // [SCENARIO] SetMappingFiltersForCustomers for VAT Registration No. implementation of mapping
        Initialize();

        // [GIVEN] VAT Registration No.
        VATRegistrationNo := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(VATRegistrationNo));
        // [GIVEN] Customer record with VAT Registration No.
        CreateCustomerWithRegistrationNo(Customer, VATRegistrationNo);
        // [GIVEN] CompanyLocation record with Tax Registration Id
        CreateLocationWithTaxId(CompanyLocation, VATRegistrationNo);
        // [GIVEN] TaxRegistrationIdMapping interface is "VAT Registration No."
        TaxRegistrationIdMapping := Enum::"Shpfy Comp. Tax Id Mapping"::"VAT Registration No.";

        // [WHEN] SetMappingFiltersForCustomers is called
        TaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);

        // [THEN] The range of the Customer record is set to the Tax Registration Id of the CompanyLocation record
        LibraryAssert.AreEqual(VATRegistrationNo, Customer.GetFilter("VAT Registration No."), 'VAT Registration No. filter is not set correctly.');
    end;


    local procedure Initialize()
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;

        IsInitialized := true;

        Commit();
    end;

    local procedure CreateCustomerWithRegistrationNo(var Customer: Record Customer; RegistrationNo: Text[50])
    begin
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer."Registration Number" := RegistrationNo;
        Customer.Insert(false);
    end;

    local procedure CreateCustomerWithVATRegNo(var Customer: Record Customer; VATRegistrationNo: Text[20])
    begin
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer."VAT Registration No." := VATRegistrationNo;
        Customer.Insert(false);
    end;

    local procedure CreateLocationWithTaxId(var CompanyLocation: Record "Shpfy Company Location"; RegistrationNo: Text[50])
    begin
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Tax Registration Id" := RegistrationNo;
        CompanyLocation.Insert(false);
    end;
}