codeunit 5100 "Create Service Demo Data"
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
        if SvcDemoDataSetup.Get() then
            exit(SvcDemoDataSetup."Is DemoData Populated");
        exit(false);
    end;

    procedure FinishCreatingServiceDemoData()
    begin
        SvcDemoDataSetup.Get();
        SvcDemoDataSetup."Is DemoData Populated" := true;
        SvcDemoDataSetup.Modify();
    end;

    procedure InitServiceDemoDataSetup()
    begin
        if SvcDemoDataSetup.Get() then
            exit;

        SvcDemoDataSetup.Init();
        SvcDemoDataSetup.Validate("Starting Year", Date2DMY(Today, 3) - 1);

        SvcDemoDataSetup."Resale Code" := RESALETok;
        SvcDemoDataSetup."Retail Code" := RETAILTok;
        SvcDemoDataSetup."VAT Prod. Posting Group Code" := VATPRODUCTTok;
        SvcDemoDataSetup."Cust. Posting Group" := CUSTPOSTINGGROUPTok;
        SvcDemoDataSetup."Cust. Gen. Bus. Posting Group" := CUSTGENBUSPGTok;
        SvcDemoDataSetup."Svc. Gen. Prod. Posting Group" := SVCGENPRODPOSTINGGROUPTok;
        SvcDemoDataSetup."Item 1 No." := ITEM1Tok;
        SvcDemoDataSetup."Item 2 No." := ITEM2Tok;
        SvcDemoDataSetup."Resource L1 No." := ResourceLocal1Tok;
        SvcDemoDataSetup."Resource L2 No." := ResourceLocal2Tok;
        SvcDemoDataSetup."Resource R1 No." := ResourceRemote1Tok;
        SvcDemoDataSetup."Resource R2 No." := ResourceRemote2Tok;
        SvcDemoDataSetup.Validate("Customer No.", CUSTTok);
        SvcDemoDataSetup."Domestic Code" := DOMESTICTok;

        SvcDemoDataSetup.Insert();

        //TODO FeatureTelemetry.LogUptake('', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure CreateSetupData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Svc Demo Accounts");
        Codeunit.Run(Codeunit::"Create Svc Setup");

        OnAfterCreateSetupData();
        Commit();
    end;

    local procedure CreateMasterData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Svc Customer Data");
        Codeunit.Run(Codeunit::"Create Svc Item Demo Data");
        Codeunit.Run(Codeunit::"Create Svc Resource Demo Data");
        Codeunit.Run(Codeunit::"Create Svc Loaners Demo Data");

        OnAfterCreateMasterData();
        Commit();
    end;

    local procedure CreateTransactionData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Svc Demo Item Stock");
        Codeunit.Run(Codeunit::"Create Svc Demo Orders");

        OnAfterCreateTransactionData();
        Commit();
    end;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
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
        ITEM1Tok: Label 'S-100', MaxLength = 20;
        ITEM2Tok: Label 'S-200', MaxLength = 20;
        ResourceLocal1Tok: Label 'LOCAL1', MaxLength = 20;
        ResourceLocal2Tok: Label 'LOCAL2', MaxLength = 20;
        ResourceRemote1Tok: Label 'REMOTE1', MaxLength = 20;
        ResourceRemote2Tok: Label 'REMOTE2', MaxLength = 20;


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