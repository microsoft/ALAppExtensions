codeunit 4799 "Create Warehousing Demo Data"
{

    procedure Create()
    begin
        if IsDemoDataPopulated() then
            exit;

        InitWarehousingDemoDataSetup();
        //TODO: Telemetry EventId?
        FeatureTelemetry.LogUptake('0000H75', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CreateSetupData();
        CreateMasterData();
        CreateTransactionData();

        FinishCreatingWarehousingDemoData();
        //TODO: Telemetry EventId?
        FeatureTelemetry.LogUsage('0000GYW', ContosoCoffeeDemoDatasetFeatureNameTok, 'DemoData creation ended');
    end;

    procedure CreateWarehousingSetupData()
    begin
        InitWarehousingDemoDataSetup();

        if IsDemoDataPopulated() then
            exit;

        CreateSetupData();

        FinishCreatingWarehousingDemoData();
    end;

    procedure IsDemoDataPopulated(): Boolean
    begin
        if WhseDemoDataSetup.Get() then
            exit(WhseDemoDataSetup."Is DemoData Populated");
        exit(false);
    end;

    procedure FinishCreatingWarehousingDemoData()
    begin
        WhseDemoDataSetup.Get();
        WhseDemoDataSetup."Is DemoData Populated" := true;
        WhseDemoDataSetup.Modify();
    end;

    procedure InitWarehousingDemoDataSetup()
    begin
        if WhseDemoDataSetup.Get() then
            exit;

        WhseDemoDataSetup.Init();
        WhseDemoDataSetup.Validate("Starting Year", Date2DMY(Today, 3) - 1);
        WhseDemoDataSetup."Auto Create Whse. Employees" := true;

        WhseDemoDataSetup."Resale Code" := XRESALETok;
        WhseDemoDataSetup."Retail Code" := XRETAILTok;
        WhseDemoDataSetup."Domestic Code" := XDOMESTICTok;
        WhseDemoDataSetup."S. Customer No." := XSMALLCUSTTok;
        WhseDemoDataSetup."S. Cust. Posting Group" := XSMALLCUSTPGTok;
        WhseDemoDataSetup."SCust. Gen. Bus. Posting Group" := XSMALLCUSTGBPGTok;
        WhseDemoDataSetup."L. Customer No." := XLARGECUSTTok;
        WhseDemoDataSetup."L. Cust. Posting Group" := XLARGECUSTPGTok;
        WhseDemoDataSetup."LCust. Gen. Bus. Posting Group" := XLARGECUSTGBPGTok;
        WhseDemoDataSetup."Vendor No." := XVENDORTok;
        WhseDemoDataSetup."Vendor Posting Group" := XVENDORPGTok;
        WhseDemoDataSetup."Vend. Gen. Bus. Posting Group" := XVENDORGBPGTok;
        WhseDemoDataSetup."Main Item No." := XMAINITEMTok;
        WhseDemoDataSetup."Complex Item No." := XCOMPLEXITEMTok;
        WhseDemoDataSetup."Location Basic" := XLOCSIMPLETok;
        WhseDemoDataSetup."Location Simple Logistics" := XLOCBASICTok;
        WhseDemoDataSetup."Location Advanced Logistics" := XLOCADVANCEDTok;

        WhseDemoDataSetup.Insert();

        //TODO: Telemetry EventId?
        FeatureTelemetry.LogUptake('0000GYV', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure CreateSetupData()
    var
    begin
        WhseDemoDataSetup.Get();

        Codeunit.Run(Codeunit::"Create Whse Demo Accounts");
        Codeunit.Run(Codeunit::"Create Whse Put Away Template");
        Codeunit.Run(Codeunit::"Create Whse ZonesBinsClasses");
        Codeunit.Run(Codeunit::"Create Whse Locations");
        Codeunit.Run(Codeunit::"Create Whse Posting Setup");
        Codeunit.Run(Codeunit::"Create Whse Item Jnl");

        OnAfterCreateSetupData();
        Commit();
    end;

    local procedure CreateMasterData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Whse Cust/Vend");
        Codeunit.Run(Codeunit::"Create Whse Item");

        OnAfterCreateMasterData();
        Commit();
    end;

    local procedure CreateTransactionData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Whse Orders");

        OnAfterCreateTransactionData();
        Commit();
    end;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        XRESALETok: Label 'RESALE', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XRETAILTok: Label 'RETAIL', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XDOMESTICTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        XSMALLCUSTTok: Label '71000', MaxLength = 20;
        XSMALLCUSTPGTok: Label 'SMALL', MaxLength = 10;
        XSMALLCUSTGBPGTok: Label 'SMALL', MaxLength = 10;
        XLARGECUSTTok: Label '72000', MaxLength = 20;
        XLARGECUSTPGTok: Label 'LARGE', MaxLength = 10;
        XLARGECUSTGBPGTok: Label 'LARGE', MaxLength = 10;
        XVENDORTok: Label '83000', MaxLength = 20;
        XVENDORPGTok: Label 'DOMESTIC', MaxLength = 10;
        XVENDORGBPGTok: Label 'DOMESTIC', MaxLength = 10;
        XMAINITEMTok: Label 'WRB-1000', MaxLength = 20;
        XCOMPLEXITEMTok: Label 'WRB-1001', MaxLength = 20;
        XLOCBASICTok: Label 'SILVER', MaxLength = 10;
        XLOCSIMPLETok: Label 'YELLOW', MaxLength = 10;
        XLOCADVANCEDTok: Label 'WHITE', MaxLength = 10;

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
