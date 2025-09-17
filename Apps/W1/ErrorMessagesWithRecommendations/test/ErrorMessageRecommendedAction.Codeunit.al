// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Shared.Error;

using Microsoft.Shared.Error;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Dimension;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 139622 ErrorMessageRecommendedAction
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        TempErrorMessageGlobalRec: Record "Error Message" temporary;
        ErrMsgScenarioTestHelper: Codeunit ErrMsgScenarioTestHelper;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        ErrScenarioOption: Option DimMustBeBlank,DimMustBeSame,ErrFixNotImplemented,DimMustBeSameButMissing;
        AcceptRecommendationTok: Label 'The recommendations will be applied to %1 error messages. \\Do you want to continue?', Comment = '%1 - selected count';
        FixedAllAckLbl: Label 'All of your selections were processed.';
        DimensionUseRequiredActionLbl: Label 'Set the value to %1', Comment = '%1 = "Dimension Value Code" Value';

    local procedure Initialize()
    begin
        Clear(TempErrorMessageGlobalRec);
        Clear(ErrMsgScenarioTestHelper);
        ClearCollectedErrors();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,GetErrorMsgRecFromErrorMessagesPageHandler')]
    procedure VerifyErrMsgRecordForDimensionMustBeBlankError()
    var
        PurchaseHeader: Record "Purchase Header";
        DimensionSetEntry: Record "Dimension Set Entry";
        PurchaseOrderPage: TestPage "Purchase Order";
    begin
        // [SCENARIO] Extended Error Message fields are valid when the user gets an error message "Dimension must be blank" while posting purchase order
        Initialize();

        // [GIVEN] A purchase order with a dimension set entry containing a value for a vendor with default dimension value posting set to "No Code"
        ErrMsgScenarioTestHelper.SetupPurchaseOrderForDimMustBeBlankError(PurchaseHeader);

        // [WHEN] User posts the purchase order form UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        PurchaseOrderPage.Post.Invoke();

        // [THEN] Error message page opens with the error message "Dimension must be blank"
        // GetErrorMsgRecFromErrorMessagesPageHandler is used to get the error message record
        // Verify the registered error message record
        TempErrorMessageGlobalRec.TestField("Message Status", TempErrorMessageGlobalRec."Message Status"::" ");
        TempErrorMessageGlobalRec.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank);
        TempErrorMessageGlobalRec.TestField("Recommended Action Caption", 'Clear the value');
        Assert.IsSubstring(TempErrorMessageGlobalRec.Title, 'isn''t valid.');

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, PurchaseHeader."Dimension Set ID");
        TempErrorMessageGlobalRec.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessageGlobalRec.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,RecommendedActionDrillDownConfirmTrueHandler,OnSuccessMessageHandler')]
    procedure DimMustBeBlankErrorFixWithDrillDownUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can drill down on the error and fix it.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeBlank);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User drills down on the error message
        asserterror ErrorMessagesTestPage.Description.Drilldown();

        // [THEN] Error dialog is raised
        Assert.ExpectedError('must be blank');

        // [WHEN] User drills down on the recommended action and user confirms the action
        LibraryVariableStorage.Enqueue('is cleared');
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownConfirmTrueHandler is used to confirm the action
        //OnSuccessMessageHandler is used to close the success message

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure DimMustBeBlankErrorFixWithAcceptRecommendationActionUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can fix the error message by accepting the recommendation.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeBlank);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User accepts the recommended action
        LibraryVariableStorage.Enqueue(1); //Count of selected error messages
        LibraryVariableStorage.Enqueue(FixedAllAckLbl); //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesTestPage."Accept Recommended Action".Invoke(); //AcceptRecommendationConfirmHandler is used to confirm the action

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,GetErrorMsgRecFromErrorMessagesPageHandler')]
    procedure VerifyErrMsgRecordForDimensionMustBeSameError()
    var
        PurchaseHeader: Record "Purchase Header";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        PurchaseOrderPage: TestPage "Purchase Order";
    begin
        // [SCENARIO] Extended Error Message fields are valid when the user gets an error message to use same dimension code while posting purchase order
        Initialize();

        // [GIVEN] A purchase order with a dimension set entry containing a value for a vendor with default dimension value posting set to "No Code"
        ErrMsgScenarioTestHelper.SetupPurchaseOrderForDimMustBeSameError(PurchaseHeader);

        // [WHEN] User posts the purchase order form UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        PurchaseOrderPage.Post.Invoke();

        // [THEN] Error message page opens with the error message "Dimension Code must be same"
        // GetErrorMsgRecFromErrorMessagesPageHandler is used to get the error message record
        // Verify the registered error message record
        TempErrorMessageGlobalRec.TestField("Message Status", TempErrorMessageGlobalRec."Message Status"::" ");
        TempErrorMessageGlobalRec.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError);
        Assert.IsSubstring(TempErrorMessageGlobalRec.Title, 'isn''t valid.');

        LibraryDimension.FindDefaultDimension(DefaultDimension, Database::Vendor, PurchaseHeader."Buy-from Vendor No.");
        TempErrorMessageGlobalRec.TestField("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Value Code"));

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, PurchaseHeader."Dimension Set ID");
        TempErrorMessageGlobalRec.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessageGlobalRec.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,RecommendedActionDrillDownConfirmTrueHandler,OnSuccessMessageHandler')]
    procedure DimMustBeSameErrorFixWithDrillDownUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can drill down on the error and fix it.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSame);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User drills down on the error message
        asserterror ErrorMessagesTestPage.Description.Drilldown();

        // [THEN] Error dialog is raised
        Assert.ExpectedError('The Dimension Value Code must be ');

        // [WHEN] User drills down on the recommended action and user confirms the action
        LibraryVariableStorage.Enqueue('is set to');
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownConfirmTrueHandler is used to confirm the action
        //OnSuccessMessageHandler is used to close the success message

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure DimMustBeSameErrorFixWithAcceptRecommendationActionUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can fix the error message by accepting the recommendation.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSame);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User accepts the recommended action
        LibraryVariableStorage.Enqueue(1); // Count of selected error messages
        LibraryVariableStorage.Enqueue(FixedAllAckLbl); //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesTestPage."Accept Recommended Action".Invoke(); // AcceptRecommendationConfirmHandler is used to confirm the action

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,GetErrorMsgRecFromErrorMessagesPageHandler')]
    procedure VerifyErrMsgRecordForDimensionMustBeSameButMissingError()
    var
        PurchaseHeader: Record "Purchase Header";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        PurchaseOrderPage: TestPage "Purchase Order";
        AddDimensionSetLbl: Label 'Add %1 dimension set', Comment = '%1 = Dimension Code', Locked = true;
    begin
        // [SCENARIO] Extended Error Message fields are valid when the user gets an error message to use same dimension code while posting purchase order
        Initialize();

        // [GIVEN] A purchase order with a dimension set entry containing a value for a vendor with default dimension value posting set to "No Code"
        ErrMsgScenarioTestHelper.SetupPurchaseOrderForDimMustBeSameButMissingDimError(PurchaseHeader);

        // [WHEN] User posts the purchase order form UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        PurchaseOrderPage.Post.Invoke();

        // [THEN] Error message page opens with the error message "Dimension code is missing"
        // GetErrorMsgRecFromErrorMessagesPageHandler is used to get the error message record
        // Verify the registered error message record
        TempErrorMessageGlobalRec.TestField("Message Status", TempErrorMessageGlobalRec."Message Status"::" ");
        TempErrorMessageGlobalRec.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameMissingDimCodeError);
        Assert.IsSubstring(TempErrorMessageGlobalRec.Title, 'A dimension set is required');

        LibraryDimension.FindDefaultDimension(DefaultDimension, Database::Vendor, PurchaseHeader."Buy-from Vendor No.");
#pragma warning disable AA0210
        DefaultDimension.SetRange("Value Posting", DefaultDimension."Value Posting"::"Same Code");
#pragma warning restore AA0210
        DefaultDimension.FindFirst();
        TempErrorMessageGlobalRec.TestField("Recommended Action Caption", StrSubstNo(AddDimensionSetLbl, DefaultDimension."Dimension Code"));

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, PurchaseHeader."Dimension Set ID");
        TempErrorMessageGlobalRec.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,RecommendedActionDrillDownConfirmTrueHandler,OnSuccessMessageHandler')]
    procedure DimMustBeSameButMissingErrorFixWithDrillDownUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can drill down on the error and fix it.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSameButMissing);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User drills down on the error message
        asserterror ErrorMessagesTestPage.Description.Drilldown();

        // [THEN] Error dialog is raised
        Assert.ExpectedError(' is required for ');

        // [WHEN] User drills down on the recommended action and user confirms the action
        LibraryVariableStorage.Enqueue('is added');
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownConfirmTrueHandler is used to confirm the action
        //OnSuccessMessageHandler is used to close the success message

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure DimMustBeSameButMissingErrorFixWithAcceptRecommendationActionUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
        DimSetId: Integer;
    begin
        // [SCENARIO] User can fix the error message by accepting the recommendation.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeSameButMissing);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        DimSetId := PurchaseHeader."Dimension Set ID";

        // [WHEN] User accepts the recommended action
        LibraryVariableStorage.Enqueue(1); // Count of selected error messages
        LibraryVariableStorage.Enqueue(FixedAllAckLbl); //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesTestPage."Accept Recommended Action".Invoke(); // AcceptRecommendationConfirmHandler is used to confirm the action

        // [THEN] Error message status is updated to "Fixed"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [THEN] Dimension Set ID should be different
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseHeader."No."); //Refresh the purchase order record
        Assert.AreNotEqual(PurchaseHeader."Dimension Set ID", DimSetId, 'Dimension Set ID should change after fixing the error');

        // [WHEN] User posts the purchase order again
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] No error is raised
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,VerifyDefaultDimensionPageHandler,VerifyDimensionSetEntryPageHandler')]
    procedure FactBoxDrillDownOpensCorrectPageForPurchaseOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO] User can drill down to the Source, Context and Sub-Context from the error message fact box.
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.PickRandomDimensionErrorScenarioForPO(PurchaseHeader, ErrorMessagesTestPage);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope

        // [WHEN] User drills down to the source
        LibraryVariableStorage.Enqueue(Database::Vendor);
        LibraryVariableStorage.Enqueue(PurchaseHeader."Buy-from Vendor No.");
        ErrorMessagesTestPage."Error Messages Card Part"."Source".Drilldown();

        // [THEN] Default dimension page for the vendor opens
        // VerifyDefaultDimensionPageHandler is used to verify the default dimension page for the vendor

        // [WHEN] User drills down to the context
        LibraryVariableStorage.Enqueue(PurchaseHeader."Dimension Set ID");
        ErrorMessagesTestPage."Error Messages Card Part"."Context".Drilldown();

        // [THEN] Dimension set entry page opens for purchase order
        // VerifyDimensionSetEntryPageHandler is used to verify the dimension set entry page

        // [WHEN] User drills down to the sub-context
        LibraryVariableStorage.Enqueue(PurchaseHeader."Dimension Set ID");
        ErrorMessagesTestPage."Error Messages Card Part"."Sub-Context Record ID".Drilldown();

        // [THEN] Dimension set entry page opens
        // VerifyDimensionSetEntryPageHandler is used to verify the dimension set entry page

        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,RecommendedActionDrillDownHandler,OnSuccessMessageTrueHandler')]
    procedure RecommendedActionDrillDownAndApplyRecommendationsScenariosUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO] Recommended Action field and Apply Recommendations action should only work for the errors with fix implementation and not fixed errors
        Initialize();

        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.PickRandomDimensionErrorScenarioForPO(PurchaseHeader, ErrorMessagesTestPage);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope

        // [WHEN] User can drill down on the recommended action and user confirm the action
        LibraryVariableStorage.Enqueue(true);
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownHandler is used to confirm the action

        // [WHEN] The Error Message status is fixed
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated to Fixed');

        // [WHEN] User drills down on the recommended action
        ErrorMessagesTestPage."Recommended Action".Drilldown();

        // [THEN] Nothing happens
        //RecommendedActionDrillDownHandler will not be triggered.

        // [WHEN] User accepts the recommended action
        ErrorMessagesTestPage."Accept Recommended Action".Invoke();

        // [THEN] Nothing happens
        // AcceptRecommendationConfirmHandler is not defined for the test.
        ErrorMessagesTestPage.Close();

        // [GIVEN] Error Message page from Posting of Purchase Order without fix implementation
        Clear(ErrorMessagesTestPage);
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::ErrFixNotImplemented);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope

        // [WHEN] User drills down on the recommended action
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::" ".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not correct');
        ErrorMessagesTestPage."Recommended Action".Drilldown();

        // [THEN] Nothing happens as there is no fix implementation for the error
        //RecommendedActionDrillDownHandler will not be triggered.

        // [WHEN] User accepts the recommended action
        ErrorMessagesTestPage."Accept Recommended Action".Invoke();

        // [THEN] Nothing happens
        // AcceptRecommendationConfirmHandler is not defined for the test.
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,GetErrorMsgRecFromErrorMessagesPageHandler')]
    procedure RegisteredErrorMessageSystemIDIsUpdated()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrderPage: TestPage "Purchase Order";
    begin
        // [SCENARIO] Registered Error Message System ID is updated error messages is saved in the database
        Initialize();

        // [GIVEN] A purchase order with a dimension set entry containing a value for a vendor with default dimension value posting set to "No Code"
        ErrMsgScenarioTestHelper.SetupPurchaseOrderForDimMustBeBlankError(PurchaseHeader);

        // [WHEN] Post action is used to post the purchase order form the UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        PurchaseOrderPage.Post.Invoke();

        // [THEN] Registered Error Message System ID is used to link the temporary error message and registered error message.
        // GetErrorMsgRecFromErrorMessagesPageHandler is used to get the error message record
        TempErrorMessageGlobalRec.TestField("Reg. Err. Msg. System ID");
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,OnSuccessMessageHandler,AcceptRecommendationConfirmHandler')]
    procedure FixingErrorsInMessagesPageShouldUpdateErrMsgRegister()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessageRec: Record "Error Message";
        PurchaseOrderPage: TestPage "Purchase Order";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO] Fixing the error messages on the temporary error message page should update the errors for Error Message Register.
        Initialize();

        // [GIVEN] A purchase order with a dimension set entry containing a value for a vendor with default dimension value posting set to "No Code"
        ErrMsgScenarioTestHelper.SetupPurchaseOrderForDimMustBeBlankError(PurchaseHeader);

        // [WHEN] Post action is used to post the purchase order form the UI
        PurchaseOrderPage.OpenEdit();
        PurchaseOrderPage.GoToRecord(PurchaseHeader);

        ErrorMessagesTestPage.Trap();
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        PurchaseOrderPage.Post.Invoke();

        // [THEN] Error message page opens with a temporary error message
        ErrorMessagesTestPage.First();

        // Find the corresponding Error Message in the database 
        ErrMsgScenarioTestHelper.FindRegisteredErrorMessage(ErrorMessagesTestPage, ErrorMessageRec);

        // [WHEN] Accept Recommendation for the error message
        ErrorMessagesTestPage.First();
        LibraryVariableStorage.Enqueue(1); //Count of selected error messages
        LibraryVariableStorage.Enqueue(FixedAllAckLbl); //OnSuccessMessageHandler is used to close the success message
        Commit(); //To ensure that the error message are registered before asserterror
        asserterror Error(''); //To allow Codeunit.Run with if then
        ErrorMessagesTestPage."Accept Recommended Action".Invoke(); //AcceptRecommendationConfirmHandler is used to confirm the action

        // [THEN] Error message status is updated for the registered error message
        ErrorMessageRec.Reset();
        ErrorMessageRec.SetRecFilter();
        ErrorMessageRec.FindFirst();
        ErrorMessageRec.TestField("Message Status", TempErrorMessageGlobalRec."Message Status"::Fixed);
    end;

    [PageHandler]
    procedure GetErrorMsgRecFromErrorMessagesPageHandler(var ErrorMessagesPage: Page "Error Messages")
    begin
        ErrorMessagesPage.GetRecord(TempErrorMessageGlobalRec);
    end;

    [ModalPageHandler]
    procedure VerifyDimensionSetEntryPageHandler(var EditDimensionSetEntriesPage: TestPage "Edit Dimension Set Entries")
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        PODimSetEntryID: Integer;
    begin
        DimensionSetEntry.SetFilter("Dimension Set ID", EditDimensionSetEntriesPage.Filter.GetFilter("Dimension Set ID"));
        DimensionSetEntry.FindFirst();
        PODimSetEntryID := LibraryVariableStorage.DequeueInteger();
        Assert.AreEqual(PODimSetEntryID, DimensionSetEntry."Dimension Set ID", 'The dimension set entry is not correct');
    end;

    [PageHandler]
    procedure VerifyDefaultDimensionPageHandler(var DefaultDimensionsPage: Page "Default Dimensions")
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimensionTableId: Integer;
        DefaultDimensionNo: Code[20];
    begin
        DefaultDimensionsPage.GetRecord(DefaultDimension);
        DefaultDimensionTableId := LibraryVariableStorage.DequeueInteger();
        DefaultDimensionNo := CopyStr(LibraryVariableStorage.DequeueText(), 1, 20);
        Assert.AreEqual(DefaultDimensionTableId, DefaultDimension."Table ID", 'The table id is not correct');
        Assert.AreEqual(DefaultDimensionNo, DefaultDimension."No.", 'The no is not correct');
    end;

    [ConfirmHandler]
    procedure RecommendedActionDrillDownConfirmTrueHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure RecommendedActionDrillDownHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure OnSuccessMessageHandler(Message: Text[1024])
    begin
        Assert.IsSubstring(Message, LibraryVariableStorage.DequeueText());
    end;

    [MessageHandler]
    procedure OnSuccessMessageTrueHandler(Message: Text[1024])
    begin
    end;

    [ConfirmHandler]
    procedure AcceptRecommendationConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.AreEqual(Question, StrSubstNo(AcceptRecommendationTok, LibraryVariableStorage.DequeueInteger()), 'The question is not correct');
        Reply := true;
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure PostOrderStrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;
}
