codeunit 148089 "Check User Setup Dim. CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [User Setup] [Dimensions] [Error Message]
    end;

    var
        Assert: Codeunit Assert;
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryErrorMessage: Codeunit "Library - Error Message";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        MustEnterDimErr: Label 'You must enter dimension %1.', Comment = '%1 = dimension code';
        DimCodeMustBeErr: Label 'Dimension Value Code %1 must match the filter %2.', Comment = '%1 = dimension value code, %2 = filter';

    [Test]
    [HandlerFunctions('SelectedDimModalPageHandler,EditDimensionSetEntriesModalPageHandler')]
    procedure SalesHeaderWithMissedSelectedDimensionValue()
    var
        SalesHeader: Record "Sales Header";
        DimensionValue: array[2] of Record "Dimension Value";
        UserSetup: Record "User Setup";
        ErrorMessage: Record "Error Message";
        ErrorMessagesPage: TestPage "Error Messages";
        UserSetupPage: TestPage "User Setup";
        CustomerNo: Code[20];
        ExpectedErrorMessage: array[10] of Text;
        ErrCreationDateTime: DateTime;
    begin
        // [FEATURE] [Sales] [UI]
        // [SCENARIO] Failed posting opens "Error Messages" page that contains two lines for missed selected dimension.
        Initialize();
        // [GIVEN] "User Checks Allowed" is 'Yes' in General Ledger Setup and "Check Dimension Values" is 'Yes' in User Setup
        EnableUserCheckDimValues(UserSetup);
        // [GIVEN] Customer 'A'
        CustomerNo := LibrarySales.CreateCustomerNo();
        // [GIVEN] Dimension value 'Department' is selected for current User Setup, where "Dimension Value Filter" is 'X'
        CreateUserSelectedDimension(DimensionValue[1], ExpectedErrorMessage);
        CreateDefaultDimForCustomer(DimensionValue[2], CustomerNo);
        // [GIVEN] Sales Order '1002', where "Sell-To Customer No." is 'A', and dimension 'Department' is not set.
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);

        // [WHEN] Post Sales Order '1002'
        ErrCreationDateTime := CurrentDateTime();
        PostSalesDocument(SalesHeader, Codeunit::"Sales-Post");

        // [THEN] Opened page "Error Messages" with two lines, where "Error Message" are:
        // [THEN] 'You must enter dimension Department' and 'Dimension Value Code Department must match the filter X.'
        // [THEN] "Context" is 'Sales Header: Order, 1002'; "Source" is 'User Setup: USERID', "Field Name" is 'Check Dimension Values'
        VerifyHeaderDimError(SalesHeader.RecordId, UserSetup.RecordId, ExpectedErrorMessage, ErrCreationDateTime);
        LibraryErrorMessage.GetTestPage(ErrorMessagesPage);
        ErrorMessagesPage.First();

        // [WHEN] Run action "Open Related Record"
        UserSetupPage.Trap();
        ErrorMessagesPage.OpenRelatedRecord.Invoke();
        // [THEN] "User Setup" page is open on USERID.
        UserSetupPage."User ID".AssertEquals(UserId);

        // [WHEN] DrillDown on 'Source'
        FindRegisteredErrorMessage(ErrorMessage, ErrorMessagesPage, ErrCreationDateTime);
        ErrorMessage.HandleDrillDown(ErrorMessage.FieldNo("Record ID")); // handled by SelectedDimModalPageHandler

        // [THEN] Opened page "Dimension Selection-Change", where Dimension 'Department' has "Selected" set to 'Yes'
        Assert.AreEqual(DimensionValue[1]."Dimension Code", LibraryVariableStorage.DequeueText(), 'Dim Code from pag567');

        // [WHEN] DrillDown on 'Context'
        ErrorMessage.HandleDrillDown(ErrorMessage.FieldNo("Context Record ID")); // handled by EditDimensionSetEntriesModalPageHandler

        // [THEN] Opened page "Edit Dimension Set Entries" for Sales Order header
        Assert.AreEqual(
          Format(SalesHeader."Dimension Set ID"),
          LibraryVariableStorage.DequeueText(), 'DimSetID filter'); // handled by EditDimensionSetEntriesModalPageHandler
    end;

    [Test]
    [HandlerFunctions('SelectedDimModalPageHandler,EditDimensionSetEntriesModalPageHandler')]
    procedure PurchHeaderWithMissedSelectedDimensionValue()
    var
        PurchaseHeader: Record "Purchase Header";
        DimensionValue: array[2] of Record "Dimension Value";
        UserSetup: Record "User Setup";
        ErrorMessage: Record "Error Message";
        ErrorMessagesPage: TestPage "Error Messages";
        UserSetupPage: TestPage "User Setup";
        VendorNo: Code[20];
        ExpectedErrorMessage: array[10] of Text;
        ErrCreationDateTime: DateTime;
    begin
        // [FEATURE] [Purchase] [UI]
        // [SCENARIO] Failed posting opens "Error Messages" page that contains two lines for missed selected dimension.
        Initialize();
        // [GIVEN] "User Checks Allowed" is 'Yes' in General Ledger Setup and "Check Dimension Values" is 'Yes' in User Setup
        EnableUserCheckDimValues(UserSetup);
        // [GIVEN] Vendor 'A'
        VendorNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] Dimension value 'Department' is selected for current User Setup, where "Dimension Value Filter" is 'X'
        CreateUserSelectedDimension(DimensionValue[1], ExpectedErrorMessage);
        CreateDefaultDimForVendor(DimensionValue[2], VendorNo);
        // [GIVEN] Purchase Order '1002', where "Buy-from Vendor No." is 'A', and dimension 'Department' is not set.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);

        // [WHEN] Post Purchase Order '1002'
        ErrCreationDateTime := CurrentDateTime();
        PostPurchDocument(PurchaseHeader, Codeunit::"Purch.-Post");

        // [THEN] Opened page "Error Messages" with two lines, where "Error Message" are:
        // [THEN] 'You must enter dimension Department' and 'Dimension Value Code Department must match the filter X.'
        // [THEN] "Context" is 'Purchase Header: Order, 1002'; "Source" is 'User Setup: USERID', "Field Name" is 'Check Dimension Values'
        VerifyHeaderDimError(PurchaseHeader.RecordId, UserSetup.RecordId, ExpectedErrorMessage, ErrCreationDateTime);
        LibraryErrorMessage.GetTestPage(ErrorMessagesPage);
        ErrorMessagesPage.First();

        // [WHEN] Run action "Open Related Record"
        UserSetupPage.Trap();
        ErrorMessagesPage.OpenRelatedRecord.Invoke();
        // [THEN] "User Setup" page is open on USERID.
        UserSetupPage."User ID".AssertEquals(UserId);

        // [WHEN] DrillDown on 'Source'
        FindRegisteredErrorMessage(ErrorMessage, ErrorMessagesPage, ErrCreationDateTime);
        ErrorMessage.HandleDrillDown(ErrorMessage.FieldNo("Record ID")); // handled by SelectedDimModalPageHandler
        // [THEN] Opened page "Dimension Selection-Change", where Dimension 'Department' has "Selected" set to 'Yes'
        Assert.AreEqual(DimensionValue[1]."Dimension Code", LibraryVariableStorage.DequeueText(), 'Dim Code from pag567');

        // [WHEN] DrillDown on 'Context'
        ErrorMessage.HandleDrillDown(ErrorMessage.FieldNo("Context Record ID")); // handled by EditDimensionSetEntriesModalPageHandler

        // [THEN] Opened page "Edit Dimension Set Entries" for Sales Order header
        Assert.AreEqual(
          Format(PurchaseHeader."Dimension Set ID"),
          LibraryVariableStorage.DequeueText(), 'DimSetID filter'); // handled by EditDimensionSetEntriesModalPageHandler
    end;

    local procedure Initialize()
    var
        SelectedDimension: Record "Selected Dimension";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Check User Setup Dim. CZL");
        LibraryErrorMessage.Clear();
        SelectedDimension.DeleteAll();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Check User Setup Dim. CZL");
        LibraryApplicationArea.EnableEssentialSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Check User Setup Dim. CZL");
    end;

    local procedure CreateDefaultDimForCustomer(var DimensionValue: Record "Dimension Value"; CustomerNo: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateDefaultDimensionCustomer(
          DefaultDimension, CustomerNo, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateDefaultDimForVendor(var DimensionValue: Record "Dimension Value"; VendorNo: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateDefaultDimensionVendor(
          DefaultDimension, VendorNo, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateUserSelectedDimension(var DimensionValue: Record "Dimension Value"; var ExpectedErrorMessage: array[2] of Text)
    var
        SelectedDimension: Record "Selected Dimension";
    begin
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateSelectedDimension(SelectedDimension, 1, Database::"User Setup", '', DimensionValue."Dimension Code");
        SelectedDimension."Dimension Value Filter" := DimensionValue.Code;
        SelectedDimension.Modify();
        ExpectedErrorMessage[1] := StrSubstNo(MustEnterDimErr, DimensionValue."Dimension Code");
        ExpectedErrorMessage[2] := StrSubstNo(DimCodeMustBeErr, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    procedure EnableUserCheckDimValues(var UserSetup: Record "User Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."User Checks Allowed CZL" := true;
        GeneralLedgerSetup.Modify();

        UserSetup.Get(UserId);
        UserSetup."Check Dimension Values CZL" := true;
        UserSetup.Modify();
    end;

    local procedure PostPurchDocument(PurchaseHeader: Record "Purchase Header"; CodeunitID: Integer)
    begin
        PurchHeaderToPost(PurchaseHeader);
        LibraryErrorMessage.TrapErrorMessages();
        PurchaseHeader.SendToPosting(CodeunitID);
    end;

    local procedure PostSalesDocument(SalesHeader: Record "Sales Header"; CodeunitID: Integer)
    begin
        SalesHeaderToPost(SalesHeader);
        LibraryErrorMessage.TrapErrorMessages();
        SalesHeader.SendToPosting(CodeunitID);
    end;

    local procedure PurchHeaderToPost(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := true;
        PurchaseHeader.Modify();
        Commit();
    end;

    local procedure SalesHeaderToPost(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify();
        Commit();
    end;

    local procedure VerifyHeaderDimError(ContextRecID: RecordID; SourceRecID: RecordID; ExpectedErrorMessage: array[10] of Text; ErrCreatedDateTime: DateTime)
    var
        ErrorMessage: Record "Error Message";
        UserSetup: Record "User Setup";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        LibraryErrorMessage.GetTestPage(ErrorMessagesTestPage);

        // first line
        ErrorMessagesTestPage.First();
        FindRegisteredErrorMessage(ErrorMessage, ErrorMessagesTestPage, ErrCreatedDateTime);
        ErrorMessage.TestField("Message Type", ErrorMessage."Message Type"::Error);
        ErrorMessage.TestField("Message", ExpectedErrorMessage[1]);
        ErrorMessage.TestField("Context Record ID", ContextRecID);
        ErrorMessage.TestField("Record ID", SourceRecID);
        ErrorMessage.CalcFields("Field Name");
        ErrorMessage.TestField("Field Name", UserSetup.FieldCaption("Check Dimension Values CZL"));

        // second line
        ErrorMessagesTestPage.Next();
        FindRegisteredErrorMessage(ErrorMessage, ErrorMessagesTestPage, ErrCreatedDateTime);
        ErrorMessage.TestField("Message Type", ErrorMessage."Message Type"::Error);
        ErrorMessage.TestField("Message", ExpectedErrorMessage[2]);
        ErrorMessage.TestField("Context Record ID", ContextRecID);
        ErrorMessage.TestField("Record ID", SourceRecID);

        // the last error is "There is nothing to post."
        ErrorMessagesTestPage.Next();
        FindRegisteredErrorMessage(ErrorMessage, ErrorMessagesTestPage, ErrCreatedDateTime);
        ErrorMessage.TestField("Message", DocumentErrorsMgt.GetNothingToPostErrorMsg());

        Assert.IsFalse(ErrorMessagesTestPage.Next(), 'There are more error messages than expected');
    end;

    local procedure FindRegisteredErrorMessage(var ErrorMessage: Record "Error Message"; ErrorMessagesTestPage: TestPage "Error Messages"; CreatedDateTime: DateTime)
    begin
        ErrorMessage.SetRange(Message, ErrorMessagesTestPage.Description.Value);
        ErrorMessage.SetRange("Created On", CreatedDateTime, CurrentDateTime);
        ErrorMessage.FindFirst();
    end;

    [ModalPageHandler]
    procedure SelectedDimModalPageHandler(var DimensionSelectionChangePage: TestPage "Dimension Selection-Change")
    begin
        DimensionSelectionChangePage.Filter.SetFilter(Selected, Format(true));
        Assert.IsTrue(DimensionSelectionChangePage.First(), 'not found record with Selected = TRUE');
        LibraryVariableStorage.Enqueue(DimensionSelectionChangePage.Code.Value);
    end;

    [ModalPageHandler]
    procedure EditDimensionSetEntriesModalPageHandler(var EditDimensionSetEntriesPage: TestPage "Edit Dimension Set Entries")
    begin
        LibraryVariableStorage.Enqueue(EditDimensionSetEntriesPage.Filter.GetFilter("Dimension Set ID"));
    end;
}

