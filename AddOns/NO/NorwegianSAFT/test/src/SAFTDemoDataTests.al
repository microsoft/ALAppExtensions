codeunit 148100 "SAF-T Demodata Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [DEMO]
    end;

    [Test]
    procedure DimensionsInitialized()
    var
        Dimension: Record Dimension;
    begin
        // [SCENARIO 309923] All dimensions have "SAF-T Analysis Type" and "Export To SAF-T" turned on after extension installation

        Initialize();
        Dimension.SetRange("SAF-T Analysis Type", '');
        Assert.RecordIsEmpty(Dimension);
        Dimension.SetRange("SAF-T Analysis Type");
        Dimension.SetRange("Export to SAF-T", false);
        Assert.RecordIsEmpty(Dimension);
    end;

    [Test]
    procedure VATPostingSetupInitialized()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO 309923] All VAT Posting Setup have "Sales SAF-T Tax Code" and "Purchase SAF-T Tax Code" after extension installation

        Initialize();
        VATPostingSetup.SetRange("Sales SAF-T Tax Code", 0);
        Assert.RecordIsEmpty(VATPostingSetup);
        VATPostingSetup.SetRange("Sales SAF-T Tax Code");
        VATPostingSetup.SetRange("Purchase SAF-T Tax Code", 0);
        Assert.RecordIsEmpty(VATPostingSetup);
    end;

    [Test]
    procedure MediaFilesExists()
    var
        MediaResources: Record "Media Resources";
    begin
        // [SCENARIO 309923] Media files with XML files for mapping exists

        Initialize();
        MediaResources.Get('General_Ledger_Standard_Accounts_4_character.xml');
        MediaResources.Get('General_Ledger_Standard_Accounts_4_character.xml');
        MediaResources.Get('KA_Grouping_Category_Code.xml');
        MediaResources.Get('RF-1167_Grouping_Category_Code.xml');
        MediaResources.Get('RF-1175_Grouping_Category_Code.xml');
        MediaResources.Get('RF-1323_Grouping_Category_Code.xml');
        MediaResources.Get('Standard_Tax_Codes.xml');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Demodata Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Demodata Tests");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Demodata Tests");
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
}
