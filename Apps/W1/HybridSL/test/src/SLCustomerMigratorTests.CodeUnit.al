// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

codeunit 47200 "SL Customer Migrator Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        SLCustomer: Record "SL Customer";
    begin
        // Delete/empty buffer table
        SLCustomer.DeleteAll();

        if IsInitialized then
            exit;
        IsInitialized := true;
    end;

    [Test]
    procedure TestProcessAllCustomers()
    var
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLCustomersAllInstream: InStream;
        BCCustomerAllInstream: InStream;
    begin
        Initialize();

        // Setup - Import CSV file to buffer
        GetInputStreamFromResource('datasets/input/SLCustomerAll.csv', SLCustomersAllInstream);
        PopulateCustomerBufferTable(SLCustomersAllInstream);
    end;

    local procedure GetInputStreamFromResource(ResourcePath: Text; var ResInstream: InStream)
    begin
        NavApp.GetResource(ResourcePath, ResInstream);
    end;

    local procedure PopulateCustomerBufferTable(var Instream: InStream)
    begin
        // Populate Customer buffer table
        Xmlport.Import(Xmlport::"SL Import Customer Data", Instream);
    end;
}
