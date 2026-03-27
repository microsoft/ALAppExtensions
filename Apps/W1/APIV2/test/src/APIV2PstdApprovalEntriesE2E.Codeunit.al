codeunit 139911 "APIV2 PstdApprovalEntries E2E"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        ServiceNameTxt: Label 'postedApprovalEntries';


    [Test]
    procedure TestGetPostedApprovalEntries()
    var
        PostedApprovalEntry: Record "Posted Approval Entry";
        SalesHeader: Record "Sales Header";
        ApprovalEntryId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Check that posted approval entries can be retrieved via API

        // [GIVEN] a Sales order exists
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [GIVEN] the sales order has an approved approval entry
        CreatePostedApprovalEntryBasic(PostedApprovalEntry, Database::"Sales Header", SalesHeader."No.", Enum::"Approval Status"::Approved, Enum::"Workflow Approval Limit Type"::"Approval Limits", SalesHeader.RecordId(), Enum::"Workflow Approval Type"::Approver, Today(), SalesHeader.Amount);
        ApprovalEntryId := Format(PostedApprovalEntry.SystemId);

        Commit();

        // [WHEN] we GET the entry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(ApprovalEntryId, Page::"APIV2 - Pstd. Approval Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', ApprovalEntryId), 'Could not find posted approval entry');
    end;

    local procedure CreatePostedApprovalEntryBasic(var PostedApprovalEntry: Record "Posted Approval Entry"; TableId: Integer; DocumentNo: Code[20]; StatusOption: Enum "Approval Status"; LimitType: Enum "Workflow Approval Limit Type"; RecID: RecordID; ApprovalType: Enum "Workflow Approval Type"; DueDate: Date; AmountDec: Decimal)
    begin
        PostedApprovalEntry.Init();
        PostedApprovalEntry."Table ID" := TableId;
        PostedApprovalEntry."Document No." := DocumentNo;
        PostedApprovalEntry."Sequence No." := LibraryRandom.RandIntInRange(10000, 100000);
        PostedApprovalEntry.Status := StatusOption;
        PostedApprovalEntry."Limit Type" := LimitType;
        PostedApprovalEntry."Posted Record ID" := RecID;
        PostedApprovalEntry."Approval Type" := ApprovalType;
        PostedApprovalEntry."Due Date" := DueDate;
        PostedApprovalEntry.Amount := AmountDec;
        PostedApprovalEntry."Approver ID" := CopyStr(UserId(), 1, 50);
        PostedApprovalEntry.Insert();
    end;

}