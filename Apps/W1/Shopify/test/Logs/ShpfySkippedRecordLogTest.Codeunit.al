codeunit 139581 "Shpfy Skipped Record Log Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        ShpfySkipRecordMgt: Codeunit "Shpfy Skip Record Mgt.";
        EmptyCustomerIdsTok: Label '{ "data": { "customers": { "pageInfo": { "hasNextPage": false }, "edges": [] } }, "extensions": { "cost": { "requestedQueryCost": 12, "actualQueryCost": 2, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1998, "restoreRate": 100 } } } }', Locked = true;

    [Test]
    procedure UnitTestLogEmptyCustomerEmail()
    var
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when customer email is empty on customer export to shopify.
        // [GIVEN] A customer record with empty email.
        Shop := ShpfyInitializeTest.CreateShop();
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        Customer."E-Mail" := '';
        Customer.Modify(false);
        Customer.SetRange("No.", Customer."No.");
        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(0);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
        ShpfyCustomerExport.Run(Customer);
        UnbindSubscription(ShpfySkippedRecordLogSub);
        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
    end;

    [Test]
    procedure UnitTestLogCustomerForSameEmailExist()
    var
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryRandom: Codeunit "Library - Random";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        SkippedRecord: Record "Shpfy Skipped Record";
        CustomerId: BigInteger;
    begin
        // [SCENARIO] Log skipped record when customer with same email already exist on customer export to shopify.
        // [GIVEN] A customer record with email that already exist in shopify.
        Shop := ShpfyInitializeTest.CreateShop();
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify customer with random guid.
        CustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := CreateGuid();
        // [GIVEN] Shop with 
        Shop."Can Update Shopify Customer" := true;
        Shop.Modify(false);
        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(ShpfyCustomer.Id);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
        ShpfyCustomerExport.Run(Customer);
        UnbindSubscription(ShpfySkippedRecordLogSub);
        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
    end;


}
