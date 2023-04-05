codeunit 4799 "Create Warehousing Demo Data"
{
    Permissions = tabledata "Warehouse Employee" = d;

    procedure Create()
    begin
        if IsDemoDataPopulated() then
            exit;

        InitWarehousingDemoDataSetup();
        FeatureTelemetry.LogUptake('0000JJH', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CreateSetupData();
        CreateMasterData();
        CreateTransactionData();

        FinishCreatingWarehousingDemoData();
        FeatureTelemetry.LogUsage('0000JJJ', ContosoCoffeeDemoDatasetFeatureNameTok, 'DemoData creation ended');
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

        WhseDemoDataSetup."Resale Code" := RESALETok;
        WhseDemoDataSetup."Retail Code" := RETAILTok;
        WhseDemoDataSetup."VAT Prod. Posting Group Code" := VATPRODUCTTok;
        WhseDemoDataSetup."Cust. Posting Group" := CUSTPOSTINGGROUPTok;
        WhseDemoDataSetup."Cust. Gen. Bus. Posting Group" := CUSTGENBUSPGTok;
        WhseDemoDataSetup."Vendor Posting Group" := VENDORPGTok;
        WhseDemoDataSetup."Vend. Gen. Bus. Posting Group" := VENDORGBPGTok;
        WhseDemoDataSetup."Item 1 No." := ITEM1Tok;
        WhseDemoDataSetup."Item 2 No." := ITEM2Tok;
        WhseDemoDataSetup."Item 3 No." := ITEM3Tok;
        WhseDemoDataSetup."Location Bin" := LOCBASICTok;
        WhseDemoDataSetup."Location Adv Logistics" := LOCSIMPLETok;
        WhseDemoDataSetup."Location Directed Pick" := LOCADVANCEDTok;
        WhseDemoDataSetup."Location In-Transit" := LOCTRANSITTok;
        WhseDemoDataSetup.Validate("Vendor No.", VENDTok);
        WhseDemoDataSetup.Validate("Customer No.", CUSTTok);
        WhseDemoDataSetup."Domestic Code" := DOMESTICTok;

        WhseDemoDataSetup.Insert();

        FeatureTelemetry.LogUptake('0000JJI', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    procedure DeleteWarehouseEmployees()
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        WarehouseEmployee.DeleteAll();
        Commit();
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
        RESALETok: Label 'RESALE', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        RETAILTok: Label 'RETAIL', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        DOMESTICTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        VATPRODUCTTok: Label 'VAT25', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        CUSTTok: Label '10000', MaxLength = 20, Locked = true;
        CUSTPOSTINGGROUPTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        CUSTGENBUSPGTok: Label 'DOMESTIC', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        VENDTok: Label '10000', MaxLength = 20, Locked = true;
        VENDORPGTok: Label 'DOMESTIC', MaxLength = 10;
        VENDORGBPGTok: Label 'DOMESTIC', MaxLength = 10;
        ITEM1Tok: Label 'WRB-1000', MaxLength = 20;
        ITEM2Tok: Label 'WRB-1001', MaxLength = 20;
        ITEM3Tok: Label 'WRB-1002', MaxLength = 20;
        LOCBASICTok: Label 'SILVER', MaxLength = 10;
        LOCSIMPLETok: Label 'YELLOW', MaxLength = 10;
        LOCADVANCEDTok: Label 'WHITE', MaxLength = 10;
        LOCTRANSITTok: Label 'OWN LOG.', MaxLength = 10;

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
