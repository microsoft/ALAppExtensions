codeunit 139901 "Service Declaration Demo Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [Demo]
        IsInitialized := false;
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryServiceDeclaration: Codeunit "Library - Service Declaration";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    procedure ServDeclSetupIsReadyToGo()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchFieldGrouping: Record "Data Exch. Field Grouping";
        ExpectedColumnCount: Integer;
    begin
        // [SCENARIO 437878] A service declaration setup is ready to go after initialization

        Initialize();
        LibraryServiceDeclaration.GetInitializedServDeclSetup(ServDeclSetup);
        ServDeclSetup.TestField("Declaration No. Series");
        ServDeclSetup.TestField("Data Exch. Def. Code");
        ServDeclSetup.TestField("Enable VAT Registration No.", false);
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        Assert.RecordCount(VATReportsConfiguration, 1);
        VATReportsConfiguration.FindFirst();
        VATReportsConfiguration.TestField("Suggest Lines Codeunit ID");
        VATReportsConfiguration.TestField("Submission Codeunit ID");

        DataExchDef.Get(ServDeclSetup."Data Exch. Def. Code");
        DataExchDef.TestField("File Type", DataExchDef."File Type"::"Variable Text");
        DataExchDef.TestField(Type, DataExchDef.Type::"Generic Export");
        DataExchDef.TestField("Reading/Writing Codeunit", Codeunit::"Exp. Writing Gen. Jnl.");
        DataExchDef.TestField("Reading/Writing XMLport", Xmlport::"Export Generic Fixed Width");
        DataExchDef.TestField("Ext. Data Handling Codeunit", Codeunit::"Exp. External Data Gen. Jnl.");
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        Assert.RecordCount(DataExchLineDef, 1);
        DataExchLineDef.FindFirst();
        ExpectedColumnCount := 5;
        DataExchLineDef.TestField("Column Count", ExpectedColumnCount);
        DataExchMapping.Get(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, Database::"Service Declaration Line");
        DataExchFieldMapping.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        Assert.RecordCount(DataExchFieldMapping, ExpectedColumnCount);
        DataExchFieldGrouping.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        Assert.RecordCount(DataExchFieldGrouping, 3);
    end;

    [Test]
    procedure AssistedSetupForServDeclarationFeature()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        // [SCENARIO 437878] An assisted setup exists for the service declartation feature
        Initialize();
        GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Serv. Decl. Setup Wizard");
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Declaration Demo Tests");

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Declaration Demo Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Service Declaration Demo Tests");
    end;
}
