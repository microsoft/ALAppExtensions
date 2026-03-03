codeunit 139910 "APIV2 - Approval Entries E2E"
{

    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryApproval: Codeunit "Library - Document Approvals";
        LibrarySales: Codeunit "Library - Sales";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        ServiceNameTxt: Label 'approvalEntries';


    [Test]
    procedure TestGetApprovalEntries()
    var
        ApprovalEntry: Record "Approval Entry";
        SalesHeader: Record "Sales Header";
        ApprovalEntryId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Check that approval entries can be retrieved via API

        // [GIVEN] a Sales order exists
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [GIVEN] the sales order has an approval entry
        LibraryApproval.CreateApprovalEntryBasic(ApprovalEntry, Database::"Sales Header", Enum::"Approval Document Type"::Order, SalesHeader."No.", Enum::"Approval Status"::Open, Enum::"Workflow Approval Limit Type"::"Approval Limits", SalesHeader.RecordId(), Enum::"Workflow Approval Type"::Approver, Today(), SalesHeader.Amount);
        ApprovalEntryId := Format(ApprovalEntry.SystemId);

        Commit();

        // [WHEN] we GET the entry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(ApprovalEntryId, Page::"APIV2 - Approval Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', ApprovalEntryId), 'Could not find approval entry');
    end;
}