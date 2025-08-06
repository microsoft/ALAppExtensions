// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;

codeunit 134245 "Shpfy Company Mapping Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        ShopifyInitializeTest: Codeunit "Shpfy Initialize Test";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestFindMappingByDefaultCompanyMapping()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        FindMappingResult: Boolean;
    begin
        // [SCENARIO] FindMapping using DefaultCompanyMapping
        Initialize();

        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shop with Company Mapping Type as Default Company Mapping
        SetDefaultCompanyMapping(Customer);
        // [GIVEN] Shopify Company with customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, Customer.SystemId);

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
    end;

    [Test]
    procedure UnitTestDoMappingByDefaultCompanyMappingWithRandomGuid()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCustomer: Record "Shpfy Customer";
        FindMappingResult: Boolean;
    begin
        // [SCENARIO] DoMapping using DefaultCompanyMapping with random guid for Shopify Company Customer System Id
        Initialize();

        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shop with Company Mapping Type as Default Company Mapping
        SetDefaultCompanyMapping(Customer);
        // [GIVEN] Shopify Company with random guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, CreateGuid());
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, 0);

        // [WHEN] FindMapping is invoked
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] FindMapping result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Shopify Customer is created
        LibraryAssert.IsTrue(ShopifyCustomer.Get(TempShopifyCustomer.Id), 'Shopify Customer was not created.');
        // [THEN] Shopify Customer has the same customer system id as the Customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCustomer."Customer SystemId", 'Customer system Id not transferred to shopify customer.');
        // [THEN] Shopify Company has the same customer system id as the Customer record
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
        // [THEN] Shopify Company main contact customer id is the same as the Shopify Customer id
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Main Contact Customer Id different than customer id.');
    end;

    [Test]
    procedure UnitTestDoMappingByDefaultCompanyMappingWithEmptyGuid()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCustomer: Record "Shpfy Customer";
        FindMappingResult: Boolean;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] DoMapping using DefaultCompanyMapping with empty guid for Shopify Company Customer System Id
        Initialize();

        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shop with Company Mapping Type as Default Company Mapping
        SetDefaultCompanyMapping(Customer);
        // [GIVEN] Shopify Company with empty guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, 0);

        // [WHEN] FindMapping is invoked
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] FindMapping result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Shopify Customer is created
        LibraryAssert.IsTrue(ShopifyCustomer.Get(TempShopifyCustomer.Id), 'Shopify Customer was not created.');
        // [THEN] Shopify Customer has the same customer system id as the Customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCustomer."Customer SystemId", 'Customer system Id not transferred to shopify customer.');
        // [THEN] Shopify Company has the same customer system id as the Customer record
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
        // [THEN] Shopify Company main contact customer id is the same as the Shopify Customer id
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Main Contact Customer Id different than customer id.');
    end;

    [Test]
    procedure UnitTestDoMappingByDefaultCompanyMappingWithExistingShopifyCustomer()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCustomer: Record "Shpfy Customer";
        ShopifyCustomerId: BigInteger;
        FindMappingResult: Boolean;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] DoMapping using DefaultCompanyMapping with existing Shopify Customer
        Initialize();

        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shop with Company Mapping Type as Default Company Mapping
        SetDefaultCompanyMapping(Customer);
        // [GIVEN] Shopify Company with customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);
        // [GIVEN] Shopify Customer
        ShopifyCustomerId := Any.IntegerInRange(10000, 99999);
        CreateShopifyCustomer(ShopifyCustomer, ShopifyCustomerId);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, ShopifyCustomerId);

        // [WHEN] FindMapping is invoked
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] FindMapping result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Main Contact Customer Id is the same as the Shopify Customer id
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(ShopifyCustomerId, ShopifyCompany."Main Contact Customer Id", 'Main contact customer Id different than customer id.');
        // [THEN] Shopify company customer system id is the same as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
    end;

    [Test]
    procedure UnitTestDoMappingByDefaultCompanyMapping()
    var
        Customer: Record Customer;
        ShopifyCompanyId: BigInteger;
        DoMappingResult: Code[20];
    begin
        // [SCENARIO] DoMapping using DefaultCompanyMapping
        Initialize();

        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shop with Company Mapping Type as Default Company Mapping
        SetDefaultCompanyMapping(Customer);
        // [GIVEN] Shopify Company Id
        ShopifyCompanyId := Any.IntegerInRange(10000, 99999);

        // [WHEN] DoMapping is called
        InvokeDoMapping(ShopifyCompanyId, DoMappingResult);

        // [THEN] The result is the same as the Customer No. field of the Customer record
        LibraryAssert.AreEqual(Customer."No.", DoMappingResult, 'Mapping result is different than default company no.');
    end;

    [Test]
    procedure UnitTestFindMappingByTaxId()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        FindMappingResult: Boolean;
    begin
        // [SCENARIO] FindMapping using By Tax Id
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shopify Company with customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, Customer.SystemId);

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
    end;

    [Test]
    procedure UnitTestFindMappingByTaxIdWithRegistrationNo()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        FindMappingResult: Boolean;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] FindMapping using By Tax Id with Registration No.
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Shop with Tax Registration Id Mapping as Registration No.
        SetCompTaxIdMapping(Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.");
        // [GIVEN] Customer with Registration No.
        CreateCustomerWithRegistrationNo(Customer);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, 0);
        // [GIVEN] Shopify Company with empty guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company Location with Tax Registration Id
        CreateCompanyLocationWithTaxId(ShopifyCompany, Customer."Registration Number");

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Shopify customer is created
        LibraryAssert.IsTrue(ShopifyCustomer.Get(TempShopifyCustomer.Id), 'Shopify Customer was not created.');
        // [THEN] Shopify customer has the same customer system id as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCustomer."Customer SystemId", 'Customer system Id not transferred to shopify customer.');
        // [THEN] Shopify company has the same customer system id as the customer record
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Customer system Id not transferred to shopify company.');
        // [THEN] Shopify company customer system id is the same as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
    end;

    [Test]
    procedure UnitTestFindMappingByTaxIdWithRegistrationNoAndRandomCustomerSysId()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCustomer: Record "Shpfy Customer";
        FindMappingResult: Boolean;
    begin
        // [SCENARIO] FindMapping using By Tax Id with Registration No. and random customer system id
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Shop with Tax Registration Id Mapping as Registration No.
        SetCompTaxIdMapping(Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.");
        // [GIVEN] Customer with Registration No.
        CreateCustomerWithRegistrationNo(Customer);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, 0);
        // [GIVEN] Shopify Company with random guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, CreateGuid());
        // [GIVEN] Company Location with Tax Registration Id
        CreateCompanyLocationWithTaxId(ShopifyCompany, Customer."Registration Number");

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Shopify customer is created
        LibraryAssert.IsTrue(ShopifyCustomer.Get(TempShopifyCustomer.Id), 'Shopify Customer was not created.');
        // [THEN] Shopify customer has the same customer system id as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCustomer."Customer SystemId", 'Customer system Id not transferred to shopify customer.');
        // [THEN] Shopify company has the same customer system id as the customer record
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Customer system Id not transferred to shopify company.');
        // [THEN] Shopify company customer system id is the same as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
    end;

    [Test]
    procedure UnitTestFindMappingByTaxIdWithRegistrationNoAndExistingShopifyCustomer()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        FindMappingResult: Boolean;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] FindMapping using By Tax Id with Registration No. and existing Shopify Customer
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Shop with Tax Registration Id Mapping as Registration No.
        SetCompTaxIdMapping(Enum::"Shpfy Comp. Tax Id Mapping"::"Registration No.");
        // [GIVEN] Customer with Registration No.
        CreateCustomerWithRegistrationNo(Customer);
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(ShopifyCustomer, 0);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, ShopifyCustomer.Id);
        // [GIVEN] Shopify Company with empty guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company Location with Tax Registration Id
        CreateCompanyLocationWithTaxId(ShopifyCompany, Customer."Registration Number");

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Main Contact Customer Id is the same as the Shopify Customer id
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Main contact customer Id different than customer id.');
        // [THEN] Shopify company customer system id is the same as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
    end;

    [Test]
    procedure UnitTestFindMappingByTaxIdWithVATRegistrationNo()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        FindMappingResult: Boolean;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] FindMapping using By Tax Id with VAT Registration No.
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Shop with Tax Registration Id Mapping as VAT Registration No.
        SetCompTaxIdMapping(Enum::"Shpfy Comp. Tax Id Mapping"::"VAT Registration No.");
        // [GIVEN] Customer with VAT Registration No.
        CreateCustomerWithVATRegistrationNo(Customer);
        // [GIVEN] Shopify Company
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company Location with Tax Registration Id
        CreateCompanyLocationWithTaxId(ShopifyCompany, Customer."VAT Registration No.");
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(ShopifyCustomer, 0);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer, ShopifyCustomer.Id);

        // [WHEN] FindMapping is called
        InvokeFindMapping(ShopifyCompany, TempShopifyCustomer, FindMappingResult);

        // [THEN] The result is true
        LibraryAssert.IsTrue(FindMappingResult, 'Mapping was not found.');
        // [THEN] Shopify company main contact customer id is the same as the Shopify Customer id
        ShopifyCompany.Get(ShopifyCompany.Id);
        LibraryAssert.AreEqual(ShopifyCustomer.Id, ShopifyCompany."Main Contact Customer Id", 'Main contact customer Id different than customer id.');
        // [THEN] Shopify company customer system id is the same as the customer record
        LibraryAssert.AreEqual(Customer.SystemId, ShopifyCompany."Customer SystemId", 'Customer system Id not transferred to shopify company.');
    end;

    [Test]
    procedure UnitTestDoMappingByTaxId()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        DoMappingResult: Code[20];
    begin
        // [SCENARIO] DoMapping using By Tax Id mapping
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shopify Company with customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, Customer.SystemId);

        // [WHEN] DoMapping is called
        InvokeDoMapping(ShopifyCompany.Id, DoMappingResult);

        // [THEN] The result is the same as the Customer No. field of the Customer record
        LibraryAssert.AreEqual(Customer."No.", DoMappingResult, 'Mapping result is different than default company no.');
    end;

    [Test]
    procedure UnitTestDoMappingByTaxIdWithEmptyGuid()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyMappingSubs: Codeunit "Shpfy Company Mapping Subs.";
        DoMappingResult: Code[20];
        EmptyGuid: Guid;
    begin
        // [SCENARIO] DoMapping using By Tax Id mapping with empty guid for Shopify Company Customer System Id
        Initialize();

        // [GIVEN] Shop with Company Mapping Type as By Tax Id
        SetMappingByTaxId();
        // [GIVEN] Customer
        CreateCustomer(Customer);
        // [GIVEN] Shopify Company with empty guid for customer system id
        CreateShopifyCompanyWithCustomerSysId(ShopifyCompany, EmptyGuid);

        // [WHEN] DoMapping is called
        BindSubscription(CompanyMappingSubs);
        InvokeDoMapping(ShopifyCompany.Id, DoMappingResult);
        UnbindSubscription(CompanyMappingSubs);

        // [THEN] Company Import codeunit is executed
        LibraryAssert.IsTrue(CompanyMappingSubs.GetCompanyImportExecuted(), 'Company Import codeunit was not executed.');
    end;


    local procedure Initialize()
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;

        Shop := ShopifyInitializeTest.CreateShop();

        IsInitialized := true;
        Commit();
    end;

    local procedure CreateShopifyCompanyWithCustomerSysId(var ShopifyCompany: Record "Shpfy Company"; CustomerSystemId: Guid)
    begin
        ShopifyCompany.Init();
        ShopifyCompany.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCompany."Shop Code" := Shop."Code";
        ShopifyCompany."Customer SystemId" := CustomerSystemId;
        ShopifyCompany.Insert(false);
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer.Insert(false);
    end;

    local procedure SetDefaultCompanyMapping(var Customer: Record Customer)
    begin
        Shop."Company Mapping Type" := Enum::"Shpfy Company Mapping"::DefaultCompany;
        Shop."Default Company No." := Customer."No.";
        Shop.Modify(false);
    end;

    local procedure CreateTempShopifyCustomer(var TempShopifyCustomer: Record "Shpfy Customer" temporary; Id: BigInteger)
    begin
        TempShopifyCustomer.Init();
        if Id <> 0 then
            TempShopifyCustomer.Id := Id
        else
            TempShopifyCustomer.Id := Any.IntegerInRange(10000, 99999);
        TempShopifyCustomer.Insert(false);
    end;

    local procedure CreateShopifyCustomer(var ShopifyCustomer: Record "Shpfy Customer"; Id: BigInteger)
    begin
        ShopifyCustomer.Init();
        if Id <> 0 then
            ShopifyCustomer.Id := Id
        else
            ShopifyCustomer.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCustomer.Insert(false);
    end;

    local procedure InvokeFindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary; var FindMappingResult: Boolean)
    var
        CompanyMapping: Codeunit "Shpfy Company Mapping";
    begin
        CompanyMapping.SetShop(ShopifyCompany."Shop Code");
        FindMappingResult := CompanyMapping.FindMapping(ShopifyCompany, TempShopifyCustomer);
    end;

    local procedure InvokeDoMapping(CompanyId: BigInteger; var DoMappingResult: Code[20])
    var
        CompanyMapping: Codeunit "Shpfy Company Mapping";
    begin
        CompanyMapping.SetShop(Shop);
        DoMappingResult := CompanyMapping.DoMapping(CompanyId, '', false)
    end;

    local procedure SetMappingByTaxId()
    begin
        Shop."Company Mapping Type" := Enum::"Shpfy Company Mapping"::"By Tax Id";
        Shop.Modify(false);
    end;

    local procedure CreateCustomerWithRegistrationNo(var Customer: Record Customer)
    begin
        CreateCustomer(Customer);
        Customer."Registration Number" := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."Registration Number"));
        Customer.Modify(false);
    end;

    local procedure CreateCompanyLocationWithTaxId(var ShopifyCompany: Record "Shpfy Company"; TaxId: Text[150])
    var
        CompanyLocation: Record "Shpfy Company Location";
    begin
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation."Tax Registration Id" := TaxId;
        CompanyLocation.Insert(false);

        ShopifyCompany."Location Id" := CompanyLocation.Id;
        ShopifyCompany.Modify(false);
    end;

    local procedure CreateCustomerWithVATRegistrationNo(var Customer: Record Customer)
    begin
        CreateCustomer(Customer);
        Customer."VAT Registration No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."VAT Registration No."));
        Customer.Modify(false);
    end;

    local procedure SetCompTaxIdMapping(ShopifyCompTaxIdMapping: Enum Microsoft.Integration.Shopify."Shpfy Comp. Tax Id Mapping")
    begin
        Shop."Shpfy Comp. Tax Id Mapping" := ShopifyCompTaxIdMapping;
        Shop.Modify(false);
    end;

}
