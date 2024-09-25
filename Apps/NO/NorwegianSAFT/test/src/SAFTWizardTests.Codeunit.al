codeunit 148101 "SAF-T Wizard Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [UI]
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryPermissions: Codeunit "Library - Permissions";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryMarketing: Codeunit "Library - Marketing";
        IsInitialized: Boolean;
        DefaultLbl: Label 'DEFAULT';

    [Test]
    procedure TwoDigitMappingCodesAndStandardTaxCodesImportsWhenSelectMappingType()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        VATReportingCode: Record "VAT Reporting Code";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
        OldVATCodeQty: Integer;
    begin
        // [SCENARIO 309923] Two-Digit SAF-T Standard Accounts imports when choose "Two Digit Standard Account" mapping type and press next

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        OldVATCodeQty := VATReportingCode.Count();

        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Two Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        // TFS ID 405028: Accounting Period, Starting Date and Ending Date fields are visible in the SAF-T Setup Wizard page
        Assert.IsTrue(SAFTSetupWizard.AccountingPeriod.Visible(), 'Accounting period field is not visible');
        Assert.IsTrue(SAFTSetupWizard.StartingDate.Visible(), 'Starting date field is not visible');
        Assert.IsTrue(SAFTSetupWizard.EndingDate.Visible(), 'Ending date field is not visible');

        SAFTMapping.SetRange("Mapping Type", SAFTMapping."Mapping Type"::"Two Digit Standard Account");
        Assert.RecordIsNotEmpty(SAFTMapping);
        Assert.IsTrue(VATReportingCode.Count() > OldVATCodeQty, 'No new VAT Codes been inserted');
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure FourDigitMappingCodesImportsWhenSelectMappingType()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Four-Digit SAF-T Standard Accounts imports when choose "Four Digit Standard Account" mapping type and press next

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);

        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMapping.SetRange("Mapping Type", SAFTMapping."Mapping Type"::"Four Digit Standard Account");
        Assert.RecordIsNotEmpty(SAFTMapping);
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure IncomeStatementMappingCodesImportsWhenSelectMappingType()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Income Statement groupings imports when choose "Income Statement" mapping type and press next

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);

        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Income Statement");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMapping.SetRange("Mapping Type", SAFTMapping."Mapping Type"::"Income Statement");
        Assert.RecordIsNotEmpty(SAFTMapping);
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure TwoDigitStandardAccountMappingBaselineCreatesAfterDefiningAccountingPeriod()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        AccountingPeriod: Record "Accounting Period";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Two-Digit Standard Account mapping baseline creates when specify period and press next

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Two Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.find();
        SAFTMappingRange.TestField("Range Type", SAFTMappingRange."Range Type"::"Accounting Period");
        VerifyTwoDigitStandardAccountMappingCreated(SAFTMappingRange.Code, SAFTMappingRange."Mapping Type");
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure FourDigitStandardAccountMappingBaselineCreatesAfterDefiningCustomDatePeriod()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        AccountingPeriod: Record "Accounting Period";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Four-Digit Standard Account mapping baseline creates when specify period and press next

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.find();
        SAFTMappingRange.TestField("Range Type", SAFTMappingRange."Range Type"::"Accounting Period");
        VerifyTwoDigitStandardAccountMappingCreated(SAFTMappingRange.Code, SAFTMappingRange."Mapping Type");
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [HandlerFunctions('MapSingleGLAccSAFTMappingSetupCardModalPageHander')]
    procedure MapGLAccountToStandardAccount()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        GLAccount: Record "G/L Account";
        AccountingPeriod: Record "Accounting Period";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Stan can open G/L Account mapping page from the wizard and see the number of accounts mapped 

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();

        SAFTMappingRange.Find();
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindFirst();

        LibraryVariableStorage.Enqueue(SAFTMapping."Category No.");
        LibraryVariableStorage.Enqueue(SAFTMapping."No.");
        SAFTSetupWizard.OpenMappingSetup.Drilldown();

        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        SAFTSetupWizard.GLAccountsMappedInfo.AssertEquals(StrSubstNo('1/%1', GLAccount.Count()));
        LibraryVariableStorage.AssertEmpty();
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [HandlerFunctions('MapVATPostingSetupModalPageHander')]
    procedure MapVATPostingSetup()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        VATReportingCode: Record "VAT Reporting Code";
        VATPostingSetup: Record "VAT Posting Setup";
        AccountingPeriod: Record "Accounting Period";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Stan can open VAT Posting Setup mapping page from the wizard and see the number of VAT combinations mapped

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();

        VATReportingCode.FindSet();
        LibraryVariableStorage.Enqueue(VATReportingCode.Code);
        VATReportingCode.Next();
        LibraryVariableStorage.Enqueue(VATReportingCode.Code);
        SAFTSetupWizard.OpenVATMapping.Drilldown();
        SAFTSetupWizard.VATMappedInfo.AssertEquals(StrSubstNo('1/%1', VATPostingSetup.Count()));

        LibraryVariableStorage.AssertEmpty();
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [HandlerFunctions('DimensionExportModalPageHander')]
    procedure DimensionExportStep()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        Dimension: Record Dimension;
        AccountingPeriod: Record "Accounting Period";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Stan can open Dimensions mapping page from the wizard

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();

        LibraryDimension.CreateDimension(Dimension);
        LibraryVariableStorage.Enqueue(Dimension.Code);
        SAFTSetupWizard.OpenDimensionExport.Drilldown();

        Dimension.Find();
        Dimension.TestField("Export to SAF-T", false);
        LibraryVariableStorage.AssertEmpty();
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure SAFTContactStep()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        AccountingPeriod: Record "Accounting Period";
        Contact: Record Contact;
        CompanyInformation: Record "Company Information";
        SAFTSetupWizard: TestPage "SAF-T Setup Wizard";
    begin
        // [SCENARIO 309923] Stan can select SAF-T Contact No. from the list of Employees from the wizard

        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        SAFTSetupWizard.OpenEdit();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTMappingRange.Get(DefaultLbl);
        SAFTSetupWizard.MappingType.SetValue(SAFTMappingRange."Mapping Type"::"Four Digit Standard Account");
        SAFTSetupWizard.ActionNext.Invoke();
        AccountingPeriod.FindFirst();
        SAFTSetupWizard.AccountingPeriod.SetValue(AccountingPeriod."Starting Date");
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();
        SAFTSetupWizard.ActionNext.Invoke();

        LibraryMarketing.CreatePersonContact(Contact);
        SAFTSetupWizard.SAFTContactNo.SetValue(Contact."No.");
        SAFTSetupWizard.ActionNext.Invoke();

        CompanyInformation.Get();
        CompanyInformation.TestField("SAF-T Contact No.", Contact."No.");

        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Wizard Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Wizard Tests");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Wizard Tests");
    end;

    local procedure VerifyTwoDigitStandardAccountMappingCreated(MappingRangeCode: Code[20]; MappingType: Enum "SAF-T Mapping Type")
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.FindSet();
        repeat
            SAFTGLAccountMapping.Get(MappingRangeCode, GLAccount."No.");
            SAFTGLAccountMapping.TestField("Mapping Type", MappingType);
        until GLAccount.Next() = 0;
    end;

    [ModalPageHandler]
    procedure MapSingleGLAccSAFTMappingSetupCardModalPageHander(var SAFTMappingSetupCard: TestPage "SAF-T Mapping Setup Card")
    begin
        SAFTMappingSetupCard.SAFTGLAccMappingSubform.CategoryNo.SetValue(LibraryVariableStorage.DequeueText());
        SAFTMappingSetupCard.SAFTGLAccMappingSubform.No.SetValue(LibraryVariableStorage.DequeueText());
    end;

    [ModalPageHandler]
    procedure MapVATPostingSetupModalPageHander(var SAFTVATPostingSetup: TestPage "SAF-T VAT Posting Setup")
    begin
        SAFTVATPostingSetup."Sale VAT Reporting Code".SetValue(LibraryVariableStorage.DequeueText());
        SAFTVATPostingSetup."Purch. VAT Reporting Code".SetValue(LibraryVariableStorage.DequeueText());
    end;

    [ModalPageHandler]
    procedure DimensionExportModalPageHander(var Dimensions: TestPage Dimensions)
    begin
        Dimensions.Filter.SetFilter(Code, LibraryVariableStorage.DequeueText());
        Dimensions.ExportToSAFT.SetValue(false);
    end;
}
