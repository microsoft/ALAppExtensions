codeunit 148043 "DIOT Wizard Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [DIOT] [UI]
    end;

    var
        Assert: Codeunit Assert;
        LIbraryERM: Codeunit "Library - ERM";
        LibraryMXDIOT: Codeunit "Library - MX DIOT";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        IsInitialized: Boolean;
        RunAssistedSetupMsg: Label 'You must complete Assisted Setup for DIOT before running this report. \\ Do you want to open assisted setup now?';

    [Test]
    procedure DefaultDIOTTypeStepChangesAllVendors()
    var
        PurchaseAndPayablesSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        DIOTSetupWizard: TestPage "DIOT Setup Wizard";
    begin
        // [SCENARIO] Wizard step 1. When user selects Default Vendor DIOT Type and clicks 'Next'. All vendors get modified.
        Initialize();

        LibraryMXDIOT.OpenDIOTSetupWizardStep(DIOTSetupWizard, 1);
        DIOTSetupWizard.DefaultDIOTVendorType.SetValue(PurchaseAndPayablesSetup."Default Vendor DIOT Type"::Others);
        DIOTSetupWizard.ActionNext.Invoke();
        Vendor.SetFilter("DIOT Type of Operation", '<>%1', Vendor."DIOT Type of Operation"::Others);
        Assert.RecordIsEmpty(Vendor);
    end;

    [Test]
    [HandlerFunctions('SetupVendorDIOTTypeModalPageHander')]
    procedure SetupVendorDIOTTypeStep()
    var
        Vendor: Record Vendor;
        DIOTSetupWizard: TestPage "DIOT Setup Wizard";
    begin
        // [SCENARIO] Wizard step 2. User can open Setup Vendor DIOT Type page and edit DIOT Type of Operations
        Initialize();

        LibraryPurchase.CreateVendor(Vendor);

        LibraryMXDIOT.OpenDIOTSetupWizardStep(DIOTSetupWizard, 2);

        LibraryVariableStorage.Enqueue(Vendor."No.");
        LibraryVariableStorage.Enqueue(Vendor."DIOT Type of Operation"::"Prof. Services");
        DIOTSetupWizard.OpenVendorDIOTTypeList.Invoke();
        // UI Handled by SetupVendorDIOTTypeModalPageHander

        LibraryVariableStorage.AssertEmpty();
        Vendor.Find();
        Vendor.TestField("DIOT Type of Operation", Vendor."DIOT Type of Operation"::"Prof. Services");
    end;

    [Test]
    [HandlerFunctions('DIOTConceptsModalPageHandler,DIOTConceptLinksModalPageHandler,ConfirmYesHandlerSimple')]
    procedure SetupDIOTConcepts()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        DIOTConceptLink: Record "DIOT Concept Link";
        DIOTSetupWizard: TestPage "DIOT Setup Wizard";
        ConceptNo: Integer;
    begin
        // [SCENARIO] Wizard step 3. User can setup DIOT Concept Links
        Initialize();
        LibraryMXDIOT.OpenDIOTSetupWizardStep(DIOTSetupWizard, 3);

        ConceptNo := LibraryMXDIOT.FindBaseAmountConceptNo();

        LIbraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 10);

        LibraryVariableStorage.Enqueue(ConceptNo);
        LibraryVariableStorage.Enqueue(VATPostingSetup."VAT Prod. Posting Group");
        LibraryVariableStorage.Enqueue(VATPostingSetup."VAT Bus. Posting Group");
        DIOTSetupWizard.OpenDIOTConceptList.Invoke();
        // UI handled by DIOTConceptsModalPageHandler

        LibraryVariableStorage.AssertEmpty();
        DIOTConceptLink.Get(ConceptNo, VATPostingSetup."VAT Prod. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure RunningReportRedirectToWizard()
    begin
        // [SCENARIO] If assisted setup for DIOT is not completed, running report redirects to wizard
        Initialize();

        LibraryVariableStorage.Enqueue(RunAssistedSetupMsg);
        Report.Run(Report::"Create DIOT Report");
        // UI Handled by ConfirmNoHandler
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CanFinishSetup()
    var
        DIOTSetupWizard: TestPage "DIOT Setup Wizard";
    begin
        // [SCENARIO] User can finish Setup wizard by clicking 'Next' and 'Finish' buttons
        Initialize();

        LibraryMXDIOT.OpenDIOTSetupWizardStep(DIOTSetupWizard, 4);
        DIOTSetupWizard.ActionFinish.Invoke();

        Assert.IsTrue(DIOTDataMgmt.GetAssistedSetupComplete(), 'Assised Setup for wizard must be completed');
    end;

    local procedure Initialize()
    begin
        Clear(DIOTDataMgmt);
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"DIOT Wizard Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"DIOT Wizard Tests");
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"DIOT Wizard Tests");
    end;

    [ModalPageHandler]
    procedure DIOTConceptsModalPageHandler(var DIOTConcepts: TestPage "DIOT Concepts")
    var
        DIOTConcept: Record "DIOT Concept";
    begin
        DIOTConcept.Get(LibraryVariableStorage.DequeueInteger());
        DIOTConcepts.GoToRecord(DIOTConcept);
        DIOTConcepts."VAT Links Count".Drilldown();
    end;

    [ModalPageHandler]
    procedure DIOTConceptLinksModalPageHandler(var DIOTConceptLinks: TestPage "DIOT Concept Links")
    begin
        DIOTConceptLinks."VAT Prod. Posting Group".SetValue(LibraryVariableStorage.DequeueText());
        DIOTConceptLinks."VAT Bus. Posting Group".SetValue(LibraryVariableStorage.DequeueText());
        DIOTConceptLinks.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SetupVendorDIOTTypeModalPageHander(var SetupVendorDIOTType: TestPage "Setup Vendor DIOT Type")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(LibraryVariableStorage.DequeueText());
        SetupVendorDIOTType.GoToRecord(Vendor);
        SetupVendorDIOTType."DIOT Type of Operation".SetValue(LibraryVariableStorage.DequeueInteger());
        SetupVendorDIOTType.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandlerSimple(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := false;
    end;
}