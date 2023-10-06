codeunit 4783 "Manufacturing Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Manufacturing Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
    begin
        ManufacturingDemoDataSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Mfg Cap Unit of Measure");
        Codeunit.Run(Codeunit::"Create Mfg GL Account");
        Codeunit.Run(Codeunit::"Create Mfg No Series");
        Codeunit.Run(Codeunit::"Create Mfg Item Category");
        Codeunit.Run(Codeunit::"Create Mfg Item Journal Setup");
        Codeunit.Run(Codeunit::"Create Mfg Location");
        Codeunit.Run(Codeunit::"Create Mfg Posting Group");
        Codeunit.Run(Codeunit::"Create Mfg Posting Setup");
        Codeunit.Run(Codeunit::"Create Mfg Availability Setup");
        Codeunit.Run(Codeunit::"Create Mfg Order Promising");
        Codeunit.Run(Codeunit::"Create Mfg Stop Scrap");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Mfg Vendor");
        Codeunit.Run(Codeunit::"Create Mfg Item");
        Codeunit.Run(Codeunit::"Create Mfg Capacity");
        Codeunit.Run(Codeunit::"Create Mfg Prod. Routing");
        Codeunit.Run(Codeunit::"Create Mfg Prod. BOMs");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Mfg Item Jnl Line");
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}