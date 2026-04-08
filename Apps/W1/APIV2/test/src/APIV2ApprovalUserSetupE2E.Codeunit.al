codeunit 139912 "APIV2 - Approval UserSetup E2E"
{

    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryApproval: Codeunit "Library - Document Approvals";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        ServiceNameTxt: Label 'approvalUserSetup';


    [Test]
    procedure TestGetApprovalUserSetup()
    var
        UserSetup: Record "User Setup";
        UserSetupId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Check that approval user setup can be retrieved via API

        // [GIVEN] an Approval User Setup exists
        LibraryApproval.CreateMockupUserSetup(UserSetup);
        UserSetupId := Format(UserSetup.SystemId);

        Commit();

        // [WHEN] we GET the entry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(UserSetupId, Page::"APIV2 - Approval User Setup", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', UserSetupId), 'Could not find approval user setup');
    end;
}