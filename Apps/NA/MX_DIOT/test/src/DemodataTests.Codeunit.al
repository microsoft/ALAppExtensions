codeunit 148044 "DIOT Demodata Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [DIOT] [Demo]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    procedure CountryDataExists()
    var
        DIOTCountryDATA: Record "DIOT Country/Region Data";
    begin
        // [SCENARIO] DIOT Country Data is not empty
        Initialize();

        DIOTCountryDATA.SetRange("Country/Region Code", '');
        Assert.RecordIsEmpty(DIOTCountryDATA);
        DIOTCountryDATA.SetFilter("Country/Region Code", '<>%1', '');
        Assert.RecordIsNotEmpty(DIOTCountryDATA);
    end;

    [Test]
    procedure DefaultConceptsExist()
    var
        DIOTConcept: Record "DIOT Concept";
        i: Integer;
    begin
        // [SCENARIO] There are 17 default DIOT Concepts with descriptions
        Initialize();

        for i := 1 to 17 do begin
            DIOTConcept.Get(i);
            DIOTConcept.TestField(Description);
        end;
    end;

    [Test]
    procedure DIOTWizardExistsInAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetup: TestPage "Assisted Setup";
    begin
        // [SCENARIO] Assisted setup entry for DIOT exists when you open Assisted Setup page
        Initialize();

        // [WHEN] Open Assisted Setup page
        AssistedSetup.OpenView();

        // [THEN] DIOT Entry is there
        Assert.IsTrue(GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"DIOT Setup Wizard"), 'Guided Experience for DIOT must exist');

        // Clean-up
        AssistedSetup.Close();
    end;


    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"DIOT Demodata Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"DIOT Demodata Tests");
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"DIOT Demodata Tests");
    end;
}