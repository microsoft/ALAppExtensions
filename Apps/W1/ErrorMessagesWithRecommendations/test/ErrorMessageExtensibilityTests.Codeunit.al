// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Shared.Error;

using System.TestLibraries.Utilities;
using Microsoft.Purchases.Document;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;
using Microsoft.Shared.Error;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Vendor;

codeunit 139621 ErrorMessageExtensibilityTests
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        ErrMsgScenarioTestHelper: Codeunit ErrMsgScenarioTestHelper;
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        Assert: Codeunit Assert;
        ErrScenarioOption: Option DimMustBeBlank,DimMustBeSame,ErrFixNotImplemented;
        AcceptRecommendationTok: Label 'The recommendations will be applied to %1 error messages. \\Do you want to continue?', Comment = '%1 - selected count';
        AcceptRecommendationPartialTok: Label 'The recommendations will be applied to %1 out of %2 selected error messages. \\Do you want to continue?', Comment = '%1 - count of actionable error messages, %2 = Total selected count';
        FixedPartialAckLbl: Label 'Recommendations applied: %1 \Failed to apply the recommendation: %2', Comment = '%1=Fixed Count, %2=Failed to fix count';
        DimensionUseRequiredActionLbl: Label 'Set the value to %1', Comment = '%1 = "Dimension Value Code" Value';

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure AcceptRecommendationActionScenariosForFailedToFix()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessageExtensibilityTests: Codeunit ErrorMessageExtensibilityTests;
        ErrorMessagesTestPage: TestPage "Error Messages";
        i: Integer;
    begin
        // [SCENARIO] Message status is updated to Failed to fix when the error message is cannot be fixed.
        // Accept recommended action is possible on failed to fix error messages
        Initialize();

        // [GIVEN] Replace the fix implementation for Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank error to Enum::ErrMsgFixImplementationTestExt:: "Failing Fix"
        BindSubscription(ErrorMessageExtensibilityTests);
        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeBlank);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        UnbindSubscription(ErrorMessageExtensibilityTests);

        // User can accept the recommended action multiple times
        for i := 1 to 2 do begin
            // [WHEN] User accepts the recommended action
            LibraryVariableStorage.Enqueue(StrSubstNo(AcceptRecommendationTok, 1)); // Count of selected error messages
            LibraryVariableStorage.Enqueue(StrSubstNo(FixedPartialAckLbl, 0, 1)); //OnSuccessMessageHandler is used to close the success message
            ErrorMessagesTestPage."Accept Recommended Action".Invoke(); // AcceptRecommendationConfirmHandler is used to confirm the action

            // [THEN] Error message status is updated to "Failed to Fix"
            ErrorMessagesTestPage.First();
            Assert.AreEqual(Enum::"Error Message Status"::"Failed to fix".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        end;
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    procedure VerifyErrMsgsForGenJnlBackgroundDocCheckUI()
    var
        GenJournalLine1, GenJournalLine2, GenJournalLine3 : Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        // [SCENARIO] Several Error Messages are caught in Background Document Check for the general journal.
        Initialize();
        SetEnableDataCheck(true);

        // [GIVEN] 3 general journal lines which results in following errors:
        // 1. DimensionCodeMustBeBlank (failing fix)
        // 2. DimensionCodeMustBeSame
        // 3. No fix implementation for the error
        // [WHEN] Run the background document check
        MockGenJnlErrorScenarioWithBatchCheck(GenJournalLine1, GenJournalLine2, GenJournalLine3, TempErrorMessage);

        // [THEN] Error messages count = 3 and verify the error message fields.
        Assert.AreEqual(3, TempErrorMessage.Count(), 'Error messages count is not correct');

        // 1. DimensionCodeMustBeBlank (failing fix)
        TempErrorMessage.FindFirst();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::"Failing Fix");
        TempErrorMessage.TestField("Recommended Action Caption", '');
        TempErrorMessage.TestField(Title, '');

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine1."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 2. DimensionCodeMustBeSame
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError);
        Assert.IsSubstring(TempErrorMessage.Title, 'isn''t valid.');

        LibraryDimension.FindDefaultDimension(DefaultDimension, Database::Vendor, GenJournalLine2."Account No.");
        TempErrorMessage.TestField("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Value Code"));

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine2."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 3. No fix implementation for the error
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::" ");
        TempErrorMessage.TestField(Title, '');

        TempErrorMessage.TestField("Recommended Action Caption", '');

        asserterror TempErrorMessage.TestField("Sub-Context Record ID");
        asserterror TempErrorMessage.TestField("Sub-Context Field Number");
    end;

    [Test]
    procedure VerifyErrMsgsForGenJnlWithMockBackgroundDocCheck()
    var
        GenJournalLine1, GenJournalLine2, GenJournalLine3 : Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        // [SCENARIO] Several Error Messages are caught in Background Document Check for the general journal.
        Initialize();

        // [GIVEN] 3 general journal lines which results in following errors:
        // 1. DimensionCodeMustBeBlank (failing fix)
        // 2. DimensionCodeMustBeSame
        // 3. No fix implementation for the error
        // [WHEN] Run the background document check
        MockGenJnlErrorScenarioWithBatchCheck(GenJournalLine1, GenJournalLine2, GenJournalLine3, TempErrorMessage);

        // [THEN] Error messages count = 3 and verify the error message fields.
        Assert.AreEqual(3, TempErrorMessage.Count(), 'Error messages count is not correct');

        // 1. DimensionCodeMustBeBlank (failing fix)
        TempErrorMessage.FindFirst();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::"Failing Fix");
        TempErrorMessage.TestField("Recommended Action Caption", '');
        TempErrorMessage.TestField(Title, '');

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine1."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 2. DimensionCodeMustBeSame
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError);
        Assert.IsSubstring(TempErrorMessage.Title, 'isn''t valid.');

        LibraryDimension.FindDefaultDimension(DefaultDimension, Database::Vendor, GenJournalLine2."Account No.");
        TempErrorMessage.TestField("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Value Code"));

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine2."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 3. No fix implementation for the error
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::" ");
        TempErrorMessage.TestField(Title, '');

        TempErrorMessage.TestField("Recommended Action Caption", '');

        asserterror TempErrorMessage.TestField("Sub-Context Record ID");
        asserterror TempErrorMessage.TestField("Sub-Context Field Number");
    end;

    [Test]
    [HandlerFunctions('AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure AcceptRecommendationsFromGenJnlBackgroundDocumentCheck()
    var
        GenJournalLine1, GenJournalLine2, GenJournalLine3 : Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        TempErrorMessage: Record "Error Message" temporary;
        ErrorMessagesActionHandler: Codeunit ErrorMessagesActionHandler;
    begin
        // [SCENARIO] Several Error Messages are caught in Background Document Check for the general journal. Some the errors could be fixed and some of the error messages cannot be fixed using recommended action.
        Initialize();

        // [GIVEN] 3 general journal lines which results in following errors:
        // 1. DimensionCodeMustBeBlank (failing fix)
        // 2. DimensionCodeMustBeSame
        // 3. No fix implementation for the error
        // [WHEN] Run the background document check
        MockGenJnlErrorScenarioWithBatchCheck(GenJournalLine1, GenJournalLine2, GenJournalLine3, TempErrorMessage);

        // [THEN] Error messages count = 3 and verify the error message fields.
        Assert.AreEqual(3, TempErrorMessage.Count(), 'Error messages count is not correct');

        // [WHEN] Fix errors using "Accept Recommended Action"
        LibraryVariableStorage.Enqueue(StrSubstNo(AcceptRecommendationPartialTok, 2, 3)); //Count of the selected error messages
        LibraryVariableStorage.Enqueue(StrSubstNo(FixedPartialAckLbl, 1, 1)); //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesActionHandler.ExecuteActions(TempErrorMessage); //AcceptRecommendationConfirmHandler is used to confirm the action
        TempErrorMessage.Reset();

        // 1. DimensionCodeMustBeBlank (failing fix)
        TempErrorMessage.FindFirst();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::"Failed to fix");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::"Failing Fix");
        TempErrorMessage.TestField("Recommended Action Caption", '');
        TempErrorMessage.TestField(Title, '');

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine1."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 2. DimensionCodeMustBeSame
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::Fixed);
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError);
        Assert.IsSubstring(TempErrorMessage.Title, 'isn''t valid.');

        LibraryDimension.FindDefaultDimension(DefaultDimension, Database::Vendor, GenJournalLine2."Account No.");
        TempErrorMessage.TestField("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Value Code"));

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, GenJournalLine2."Dimension Set ID");
        TempErrorMessage.TestField("Sub-Context Record ID", DimensionSetEntry.RecordId);
        TempErrorMessage.TestField("Sub-Context Field Number", DimensionSetEntry.FieldNo("Dimension Value Code"));

        // 3. No fix implementation for the error
        TempErrorMessage.Next();
        TempErrorMessage.TestField("Message Status", TempErrorMessage."Message Status"::" ");
        TempErrorMessage.TestField("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::" ");
        TempErrorMessage.TestField(Title, '');

        TempErrorMessage.TestField("Recommended Action Caption", '');

        asserterror TempErrorMessage.TestField("Sub-Context Record ID");
        asserterror TempErrorMessage.TestField("Sub-Context Field Number");
    end;

    [Test]
    [HandlerFunctions('AcceptRecommendationConfirmHandler,OnSuccessMessageHandler')]
    procedure FilterFixedErrorMessagesAfterFixingErrors()
    var
        GenJournalLine1, GenJournalLine2, GenJournalLine3 : Record "Gen. Journal Line";
        TempErrorMessage: Record "Error Message" temporary;
        ErrorMessagesActionHandler: Codeunit ErrorMessagesActionHandler;
        ErrorMessagesPage: Page "Error Messages";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO] Filter fixed error using the action "Hide fixed errors" and "Show all errors"
        Initialize();

        // [GIVEN] 3 general journal lines which results in following errors:
        // 1. DimensionCodeMustBeBlank (failing fix)
        // 2. DimensionCodeMustBeSame
        // 3. No fix implementation for the error
        // [WHEN] Run the background document check
        MockGenJnlErrorScenarioWithBatchCheck(GenJournalLine1, GenJournalLine2, GenJournalLine3, TempErrorMessage);

        // [THEN] Error messages count = 3
        Assert.AreEqual(3, TempErrorMessage.Count(), 'Error messages count is not correct');

        // [WHEN] Fix errors using "Accept Recommended Action"
        LibraryVariableStorage.Enqueue(StrSubstNo(AcceptRecommendationPartialTok, 2, 3)); //Count of the selected error messages
        LibraryVariableStorage.Enqueue(StrSubstNo(FixedPartialAckLbl, 1, 1)); //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesActionHandler.ExecuteActions(TempErrorMessage); //AcceptRecommendationConfirmHandler is used to confirm the action

        // [GIVEN] Open the error messages page
        ErrorMessagesTestPage.Trap();
        ErrorMessagesPage.SetRecords(TempErrorMessage);
        ErrorMessagesPage.Run();

        // [WHEN] Filter fixed error messages
        ErrorMessagesTestPage."Hide Fixed Errors".Invoke();

        // [THEN] Error with DimensionCodeMustBeSame is hidden and two error messages are visible
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::"Failed to fix".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        ErrorMessagesTestPage.Next();
        Assert.AreEqual(Enum::"Error Message Status"::" ".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        Assert.IsFalse(ErrorMessagesTestPage.Next(), 'There are more messages than expected within the filters');

        // [WHEN] Show all error messages
        ErrorMessagesTestPage."Show All Errors".Invoke();

        // [THEN] All error messages are visible
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::"Failed to fix".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        ErrorMessagesTestPage.Next();
        Assert.AreEqual(Enum::"Error Message Status"::Fixed.AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        ErrorMessagesTestPage.Next();
        Assert.AreEqual(Enum::"Error Message Status"::" ".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        Assert.IsFalse(ErrorMessagesTestPage.Next(), 'There are more messages than expected within the filters');
    end;

    [Test]
    [HandlerFunctions('PostOrderStrMenuHandler,RecommendedActionDrillDownConfirmTrueHandler')]
    procedure MessageStatusIsFailedToFixDrillDownScenarioUI()
    var
        PurchaseHeader: Record "Purchase Header";
        ErrorMessageExtensibilityTests: Codeunit ErrorMessageExtensibilityTests;
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO] Message status is updated to Failed to fix when the error message is cannot be fixed.
        // Drill Down is possible on the failed to fix error messages
        Initialize();

        // [GIVEN] Replace the fix implementation for Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank error to Enum::ErrMsgFixImplementationTestExt:: "Failing Fix"
        BindSubscription(ErrorMessageExtensibilityTests);
        // [GIVEN] Error Message page from Posting of Purchase Order
        LibraryVariableStorage.Enqueue(3); //Receive and Invoice
        ErrMsgScenarioTestHelper.GetErrMsgTestPageFromPostingPO(PurchaseHeader, ErrorMessagesTestPage, ErrScenarioOption::DimMustBeBlank);
        asserterror Error(''); //To allow Codeunit.Run with if then within the test scope
        UnbindSubscription(ErrorMessageExtensibilityTests);

        // [WHEN] User can drill down on recommended action
        ErrorMessagesTestPage.First();
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownConfirmTrueHandler is used to confirm the action

        // [THEN] Error message status is updated to "Failed to Fix"
        ErrorMessagesTestPage.First();
        Assert.AreEqual(Enum::"Error Message Status"::"Failed to fix".AsInteger(), ErrorMessagesTestPage."Message Status".AsInteger(), 'Message status is not updated correctly');
        ErrorMessagesTestPage.Close();
    end;

    [Test]
    [HandlerFunctions('RecommendedActionDrillDownConfirmTrueHandler,OnSuccessMessageTrueHandler,ApplyCustomerEntriesModalPageHandler,ConfirmPostApplicationModalPageHandler')]
    procedure GlobalDimensionsWhenDimensionMustBeSameErrorFixWithDrillDownUI()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionValue: Record "Dimension Value";
        ErrorMessagesTestPage: TestPage "Error Messages";
    begin
        // [SCENARIO 507119] Global dimensions on G/L entry are corrected using recommented action on error message page
        // [SCENARIO 507119] When appling invoice and payment for customer on post preview, if the dimension error occurs, user can drill down on the error and fix it, dimensions are corrected and posting process is done

        // [GIVEN] Enable data check setup
        Initialize();
        SetEnableDataCheck(true);

        // [GIVEN] Disable local functionality in general ledger setup
        LibraryERMCountryData.UpdateGeneralLedgerSetup();

        // [GIVEN] Create dimensions and currency exchange rates with GL account setup
        ErrMsgScenarioTestHelper.SetupForDimensionMustBeSameError(Customer, DimensionValue);

        // [GIVEN] Post sales invoice for the customer with dimension 1 code = ''
        LibraryVariableStorage.Enqueue(PostSalesInvoice(Customer."No.", SalesHeader));

        // [GIVEN] Create payment journal for the customer with dimension 1 code = '' and post it
        CreateGenJournalLine(GenJournalLine, Customer."No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] On the customer ledger entries, apply payment with invoice entry
        // [GIVEN] Run post preview on apply cust. ledger entries. Preview posting will show recommented action for the error
        ApplyAndPostCustomerEntry(Customer."No.", GenJournalLine."Document No.", ErrorMessagesTestPage);// ApplyCustomerEntriesModalPageHandler is used to call post preview
        //ConfirmPostApplicationModalPageHandler is used to confirm post preview
        asserterror Error('');

        // [WHEN] The error dimension 1 code is missing is executed. User drills down on the recommended action on error message page and confirms the action to insert recommended global dimension 1 code
        ErrorMessagesTestPage."Recommended Action".Drilldown(); //RecommendedActionDrillDownConfirmTrueHandler is used to confirm the action
        //OnSuccessMessageHandler is used to close the success message
        ErrorMessagesTestPage.Close();

        // [GIVEN] Post applied customer entries after the global dimension 1 code is corrected
        PostAppliedCustomerEntry(GenJournalLine."Document No.");

        // [THEN] Global dimension 1 code is corrected and inserted on the new G/L entries
        VerifyAppliedEntriesDimension(GenJournalLine."Document No.", DimensionValue.Code);
    end;

    local procedure Initialize()
    begin
        Clear(ErrMsgScenarioTestHelper);
        LibraryVariableStorage.Clear();
    end;

    local procedure SetEnableDataCheck(Enabled: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Data Check", Enabled);
        GeneralLedgerSetup.Modify();
    end;

    local procedure MockFullBatchCheck(TemplateName: Code[10]; BatchName: Code[10]; var TempErrorMessage: Record "Error Message" temporary)
    var
        ErrorHandlingParameters: Record "Error Handling Parameters";
        CheckGenJnlLineBackgr: Codeunit "Check Gen. Jnl. Line. Backgr.";
        Params: Dictionary of [Text, Text];
    begin
        SetErrorHandlingParameters(ErrorHandlingParameters, TemplateName, BatchName, '', 0D, '', 0D, true, false);
        ErrorHandlingParameters.ToArgs(Params);
        Commit();
        CheckGenJnlLineBackgr.RunCheck(Params, TempErrorMessage);
    end;

    local procedure SetErrorHandlingParameters(var ErrorHandlingParameters: Record "Error Handling Parameters"; TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]; PostingDate: Date; xDocumentNo: Code[20]; xPostingDate: Date; FullBatchCheck: Boolean; LineModified: Boolean)
    begin
        ErrorHandlingParameters.Init();
        ErrorHandlingParameters."Journal Template Name" := TemplateName;
        ErrorHandlingParameters."Journal Batch Name" := BatchName;
        ErrorHandlingParameters."Document No." := DocumentNo;
        ErrorHandlingParameters."Posting Date" := PostingDate;
        ErrorHandlingParameters."Previous Document No." := xDocumentNo;
        ErrorHandlingParameters."Previous Posting Date" := xPostingDate;
        ErrorHandlingParameters."Full Batch Check" := FullBatchCheck;
        ErrorHandlingParameters."Line Modified" := LineModified;
    end;

    // 3 general journal lines which results in errors: DimensionCodeMustBeBlank (failing fix), DimensionCodeMustBeSame, No fix implementation for the error
    local procedure MockGenJnlErrorScenarioWithBatchCheck(var GenJournalLine1: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line"; var GenJournalLine3: Record "Gen. Journal Line"; var TempErrorMessage: Record "Error Message" temporary)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        ErrorMessageExtensibilityTests: Codeunit ErrorMessageExtensibilityTests;
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // 3 general journal lines which results in following errors:
        // 1. DimensionCodeMustBeBlank (failing fix)
        ErrMsgScenarioTestHelper.SetupGenJnlLineForDimMustBeBlankError(GenJournalLine1, GenJournalBatch);

        // 2. DimensionCodeMustBeSame
        ErrMsgScenarioTestHelper.SetupGenJnlLineForDimMustBeSameError(GenJournalLine2, GenJournalBatch);

        // 3. No fix implementation for the error
        ErrMsgScenarioTestHelper.SetupGenJnlLineForErrorWithoutFix(GenJournalLine3, GenJournalBatch);

        // RunCheck to mock full batch check
        BindSubscription(ErrorMessageExtensibilityTests); //Replace the fix implementation for Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank error to Enum::ErrMsgFixImplementationTestExt:: "Failing Fix"
        MockFullBatchCheck(GenJournalTemplate.Name, GenJournalBatch.Name, TempErrorMessage);
        UnbindSubscription(ErrorMessageExtensibilityTests);
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        LibraryERM.CreateBankAccount(BankAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);

        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo, -100);
        GenJournalLine.Validate("Posting Date", Today() + 5);
        GenJournalLine.Modify();
    end;

    local procedure PostAppliedCustomerEntry(DocumentNo: Code[20])
    var
        PaymentCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        LibraryERM.FindCustomerLedgerEntry(PaymentCustLedgerEntry, PaymentCustLedgerEntry."Document Type"::Payment, DocumentNo);
        LibraryERM.SetAppliestoIdCustomer(PaymentCustLedgerEntry);
        LibraryERM.PostCustLedgerApplication(PaymentCustLedgerEntry);
    end;

    local procedure ApplyAndPostCustomerEntry(CustomerNo: Code[20]; DocumentNo: Code[20]; var ErrorMessagesTestPage: TestPage "Error Messages")
    var
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        ErrorMessagesTestPage.Trap();
        CustomerLedgerEntries.OpenEdit();
        CustomerLedgerEntries.Filter.SetFilter("Customer No.", CustomerNo);
        CustomerLedgerEntries.Filter.SetFilter("Document No.", DocumentNo);

        CustomerLedgerEntries."Apply Entries".Invoke();
        CustomerLedgerEntries.Close();
        ErrorMessagesTestPage.First();
    end;

    local procedure VerifyAppliedEntriesDimension(DocumentNo: Code[20]; DimensionCode: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetLoadFields("Global Dimension 1 Code");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Payment);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Bal. Account Type", GLEntry."Bal. Account Type"::"G/L Account");
        if GLEntry.IsEmpty() then
            exit;

        if GLEntry.FindSet() then
            repeat
                GLEntry.TestField("Global Dimension 1 Code", DimensionCode);
            until GLEntry.Next() = 0;
    end;

    local procedure PostSalesInvoice(CustomerNo: Code[20]; var SalesHeader: Record "Sales Header"): Code[20]
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, CustomerNo);
        SalesHeader.Validate("Posting Date", Today());
        SalesHeader.Modify();
        exit(LibrarySales.PostSalesDocument(SalesHeader, false, true));
    end;

    [ModalPageHandler]
    procedure ApplyCustomerEntriesModalPageHandler(var ApplyCustomerEntries: TestPage "Apply Customer Entries")
    begin
        ApplyCustomerEntries.Filter.SetFilter("Document No.", LibraryVariableStorage.DequeueText());
        ApplyCustomerEntries."Set Applies-to ID".Invoke();
        ApplyCustomerEntries.Preview.Invoke();
    end;

    [ModalPageHandler]
    procedure ConfirmPostApplicationModalPageHandler(var PostApplication: TestPage "Post Application")
    begin
        PostApplication.OK().Invoke();
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
    procedure RecommendedActionDrillDownConfirmTrueHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure AcceptRecommendationConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.AreEqual(Question, LibraryVariableStorage.DequeueText(), 'The confirmation question is not correct');
        Reply := true;
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure PostOrderStrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;

    // Modify the error message to use failing fix implementation
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure TestFailToFixOnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        DimSetEntry: Record "Dimension Set Entry";
        RecRef: RecordRef;
        IErrorMessageFix: Interface ErrorMessageFix;
    begin
        if Tag <> Enum::"Error Msg. Fix Implementation".Names().Get(Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank.AsInteger() + 1) then
            exit;

        if VariantRec.IsRecord then begin
            RecRef.GetTable(VariantRec);
            if RecRef.Number = Database::"Dimension Set Entry" then begin
                RecRef.SetTable(DimSetEntry);
                ErrorMessage.Validate("Sub-Context Record ID", DimSetEntry.RecordId);
                ErrorMessage.Validate("Sub-Context Field Number", DimSetEntry.FieldNo("Dimension Value Code"));
                ErrorMessage.Validate("Message Status", ErrorMessage."Message Status"::" ");
                ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::"Failing Fix");

                // Use the interface face to set title and recommended action caption
                IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
                IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
                ErrorMessage.Modify();
            end;
        end;
    end;
}
