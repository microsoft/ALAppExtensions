codeunit 139856 "APIV2 - GenProdPostGroup E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        ERMVATToolHelper: Codeunit "ERM VAT Tool - Helper";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'generalProductPostingGroups';

    [Test]
    procedure TestGetGenProdPostGroups()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CreatedId: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] Create a General Product Posting Group and use a GET method to retrieve it
        // [GIVEN] A Gen. Prod. Post. Group
        ERMVATToolHelper.CreateGenProdPostingGroup(GenProductPostingGroup, true);
        Commit();

        CreatedId := Format(GenProductPostingGroup.SystemId);
        // [WHEN] we GET all entries from API endpoint filtering that by the created id
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(CreatedId, Page::"APIV2 - Gen. Prod. Post. Group", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);
        // [THEN] we should get it on the response.
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(
            LibraryGraphMgt.GetObjectIDFromJSON(Response, 'id', CreatedId),
            'Could not find created Gen. Prod. Post. Group on the response');

    end;

}