codeunit 139857 "APIV2 - InventoryPostGroup E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;
    trigger OnRun()
    begin
    end;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'inventoryPostingGroups';


    [Test]
    procedure TestGetInventoryPostGroups()
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        CreatedId: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] Create an Inventory Posting Group and use a GET to retrieve it
        // [GIVEN] An Inventory Posting Group
        LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);
        Commit();

        CreatedId := Format(InventoryPostingGroup.SystemId);
        // [WHEN] we GET all entries from API endpoint filtering that by the created id
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreatedId, Page::"APIV2 - Inventory Post. Group", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);
        // [THEN] we should get it on the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(
            LibraryGraphMgt.GetObjectIDFromJSON(Response, 'id', CreatedId),
            'Could not find created Inventory Posting Group on the response');
    end;

}