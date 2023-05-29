codeunit 5110 "Create Jobs Demo Data"
{
    procedure Create()
    begin
        if IsDemoDataPopulated() then
            exit;

        InitServiceDemoDataSetup();
        //TODO FeatureTelemetry.LogUptake('', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CreateSetupData();
        CreateMasterData();
        CreateTransactionData();

        FinishCreatingServiceDemoData();
        //TODO FeatureTelemetry.LogUsage('', ContosoCoffeeDemoDatasetFeatureNameTok, 'DemoData creation ended');
    end;

    procedure CreateServiceSetupData()
    begin
        InitServiceDemoDataSetup();

        if IsDemoDataPopulated() then
            exit;

        CreateSetupData();

        FinishCreatingServiceDemoData();
    end;

    procedure IsDemoDataPopulated(): Boolean
    begin
        if JobsDemoDataSetup.Get() then
            exit(JobsDemoDataSetup."Is DemoData Populated");
        exit(false);
    end;

    procedure FinishCreatingServiceDemoData()
    begin
        JobsDemoDataSetup.Get();
        JobsDemoDataSetup."Is DemoData Populated" := true;
        JobsDemoDataSetup.Modify();
    end;

    procedure InitServiceDemoDataSetup()
    begin
        if JobsDemoDataSetup.Get() then
            exit;

        JobsDemoDataSetup.Init();
        JobsDemoDataSetup.Validate("Starting Year", Date2DMY(Today, 3) - 1);

        JobsDemoDataSetup."Resale Code" := RESALETok;
        JobsDemoDataSetup."Retail Code" := RETAILTok;
        JobsDemoDataSetup."VAT Prod. Posting Group Code" := VATPRODUCTTok;
        JobsDemoDataSetup."Cust. Posting Group" := CUSTPOSTINGGROUPTok;
        JobsDemoDataSetup."Cust. Gen. Bus. Posting Group" := CUSTGENBUSPGTok;
        JobsDemoDataSetup."Item Machine No." := MachineTok;
        JobsDemoDataSetup."Item Consumable No." := ConsumableTok;
        JobsDemoDataSetup."Resource Installer No." := ResourceInstallerTok;
        JobsDemoDataSetup."Resource Vehicle No." := ResourceVehicleTok;
        JobsDemoDataSetup.Validate("Customer No.", CUSTTok);
        JobsDemoDataSetup."Domestic Code" := DOMESTICTok;
        JobsDemoDataSetup."Job Posting Group" := JOBPOSTINGGROUPTok;

        JobsDemoDataSetup.Insert();

        //TODO FeatureTelemetry.LogUptake('', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure CreateSetupData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Jobs Demo Accounts");
        Codeunit.Run(Codeunit::"Create Jobs Setup");

        OnAfterCreateSetupData();
        Commit();
    end;

    local procedure CreateMasterData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Jobs Cust Data");
        Codeunit.Run(Codeunit::"Create Job Demo Data");
        Codeunit.Run(Codeunit::"Create Job Resource Demo Data");

        OnAfterCreateMasterData();
        Commit();
    end;

    local procedure CreateTransactionData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Job Jnl Demo");

        OnAfterCreateTransactionData();
        Commit();
    end;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        RESALETok: Label 'RESALE', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        RETAILTok: Label 'RETAIL', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        DOMESTICTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        VATPRODUCTTok: Label 'VAT25', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        CUSTTok: Label '10000', MaxLength = 20, Locked = true;
        CUSTPOSTINGGROUPTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        CUSTGENBUSPGTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        SVCGENPRODPOSTINGGROUPTok: Label 'SERVICES', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        JOBPOSTINGGROUPTok: Label 'SETTING UP', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        MachineTok: Label 'AP-XL', MaxLength = 20;
        ConsumableTok: Label 'F-100', MaxLength = 20;
        ResourceInstallerTok: Label 'EDGIN', MaxLength = 20;
        ResourceVehicleTok: Label 'TOWNVAN', MaxLength = 20;


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