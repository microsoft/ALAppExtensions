codeunit 4780 "Create Manufacturing DemoData"
{
    procedure Create()
    begin
        if IsDemoDataPopulated() then
            exit;

        InitManufacturingDemoDataSetup();

        FeatureTelemetry.LogUptake('0000H75', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CreateSetupData();
        CreateMasterData();
        CreateTransactionData();

        FinishCreatingManufacturingDemoData();
        FeatureTelemetry.LogUsage('0000GYW', ContosoCoffeeDemoDatasetFeatureNameTok, 'DemoData creation ended');
    end;

    procedure CreateManufacturingSetupData()
    begin
        InitManufacturingDemoDataSetup();

        if IsDemoDataPopulated() then
            exit;

        CreateSetupData();

        FinishCreatingManufacturingDemoData();
    end;

    procedure IsDemoDataPopulated(): Boolean
    begin
        if ManufacturingDemoDataSetup.Get() then
            exit(ManufacturingDemoDataSetup."Is DemoData Populated");
        exit(false);
    end;

    procedure FinishCreatingManufacturingDemoData()
    begin
        ManufacturingDemoDataSetup.Get();
        ManufacturingDemoDataSetup."Is DemoData Populated" := true;
        ManufacturingDemoDataSetup.Modify();
    end;

    procedure InitManufacturingDemoDataSetup()
    begin
        if ManufacturingDemoDataSetup.Get() then
            exit;

        ManufacturingDemoDataSetup.Init();
        ManufacturingDemoDataSetup.Validate("Starting Year", Date2DMY(Today, 3) - 1);

        ManufacturingDemoDataSetup."Finished Code" := XFINISHEDTok;
        ManufacturingDemoDataSetup."Retail Code" := XRETAILTok;
        ManufacturingDemoDataSetup."Raw Mat Code" := XRAWMATTok;
        ManufacturingDemoDataSetup."Manufact Code" := XMANUFACTTok;
        ManufacturingDemoDataSetup."Domestic Code" := XDOMESTICTok;
        ManufacturingDemoDataSetup."Base VAT Code" := XZEROTok;
        ManufacturingDemoDataSetup."Manufacturing Location" := XNorthTok;

        ManufacturingDemoDataSetup.Insert();

        FeatureTelemetry.LogUptake('0000GYV', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure CreateSetupData()
    var
    begin
        ManufacturingDemoDataSetup.Get();

        Codeunit.Run(Codeunit::"Create Mfg Cap Unit of Measure");
        Codeunit.Run(Codeunit::"Create Mfg Setup");
        Codeunit.Run(Codeunit::"Create Mfg Demo Accounts");
        Codeunit.Run(Codeunit::"Create Mfg Item Jnl Template");
        Codeunit.Run(Codeunit::"Create Mfg Item Jnl Batch");
        Codeunit.Run(Codeunit::"Create Mfg Location");
        Codeunit.Run(Codeunit::"Create Mfg Posting Setup");
        Codeunit.Run(Codeunit::"Create Mfg Unit of Measures");
        Codeunit.Run(Codeunit::"Create Mfg Availability Setup");
        Codeunit.Run(Codeunit::"Create Mfg Order Promising");

        OnAfterCreateSetupData();
    end;

    local procedure CreateMasterData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Mfg Vendor");
        Codeunit.Run(Codeunit::"Create Mfg Item");
        Codeunit.Run(Codeunit::"Create Mfg Shop Calendar");
        Codeunit.Run(Codeunit::"Create Mfg Work Center");
        Codeunit.Run(Codeunit::"Create Mfg Stop Codes");
        Codeunit.Run(Codeunit::"Create Mfg Scrap Codes");
        Codeunit.Run(Codeunit::"Create Mfg Routing Link");
        Codeunit.Run(Codeunit::"Create Mfg Prod. BOMs");
        Codeunit.Run(Codeunit::"Create Mfg Prod. Routing");

        OnAfterCreateMasterData();
    end;

    local procedure CreateTransactionData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Mfg Item Jnl Line");

        OnAfterCreateTransactionData();
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        XFINISHEDTok: Label 'FINISHED', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XRETAILTok: Label 'RETAIL', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XRAWMATTok: Label 'RAW MAT', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XMANUFACTTok: Label 'MANUFACT', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XDOMESTICTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XZEROTok: Label 'ZERO', Locked = true;
        XNorthTok: Label 'North', MaxLength = 10;
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSetupData()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateMasterData()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransactionData()
    begin
    end;
}