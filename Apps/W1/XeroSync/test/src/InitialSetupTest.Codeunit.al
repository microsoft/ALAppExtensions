codeunit 139511 "XS Initial Setup Test"
{
    // [FEATURE] [Initial Setup]
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";

    [Test]
    procedure TestPopulateSynchronizationFieldTable()
    var
        SynchronizationField: Record "XS Synchronization Field";
        PopulateSyncFieldTable: Codeunit "XS Populate Sync Field Table";
    begin
        // [Given] Synchronization Field 
        Initialize();

        LibraryLowerPermissions.SetInvoiceApp();

        // [When] When the app is being installed this table needs to be populated (OnInstallAppPerCompany)
        PopulateSyncFieldTable.PopulateSyncFieldTableForCustomer();
        PopulateSyncFieldTable.PopulateSyncFieldTableForItem();

        // [Then] Check if the table is populated properly
        Assert.IsTrue(SynchronizationField.Count() = 17, 'There should be 17 entries in the Synchronization Field table.');
        FilterSyncFieldEntriesBasedOnTableNo(SynchronizationField, Database::Item);
        Assert.IsTrue(SynchronizationField.Count() = 5, 'Five (5) fields from the Item table should be included in comparation.');
        FilterSyncFieldEntriesBasedOnTableNo(SynchronizationField, Database::Customer);
        Assert.IsTrue(SynchronizationField.Count() = 12, 'Twelve (12) fields from the Customer table should be included in comparation.');
    end;

    local procedure Initialize()
    var
        SynchronizationField: Record "XS Synchronization Field";
    begin
        SynchronizationField.DeleteAll();
    end;

    local procedure FilterSyncFieldEntriesBasedOnTableNo(var SynchronizationField: Record "XS Synchronization Field"; TableNo: Integer)
    begin
        Clear(SynchronizationField);
        SynchronizationField.SetRange(SynchronizationField."Table No.", TableNo);
        SynchronizationField.FindFirst();
    end;
}