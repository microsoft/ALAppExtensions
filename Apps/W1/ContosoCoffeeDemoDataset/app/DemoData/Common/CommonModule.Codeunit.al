codeunit 4769 "Common Module" implements "Contoso Demo Data Module"
{
    Description = 'This module should include common data that most scenarios have dependency on.';
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Contoso Coffee Demo Data");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"];
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Sales);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Purchase);
    end;

    procedure CreateSetupData()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Common CountryOrRegion");
        Codeunit.Run(Codeunit::"Create Common Unit Of Measure");
        Codeunit.Run(Codeunit::"Create Common No Series");
        Codeunit.Run(Codeunit::"Create Common GL Account");
        Codeunit.Run(Codeunit::"Create Common Sales Setup");
        Codeunit.Run(Codeunit::"Create Common Purchase Setup");
        Codeunit.Run(Codeunit::"Create Common Inventory Setup");
        Codeunit.Run(Codeunit::"Create Common Posting Group");
        Codeunit.Run(Codeunit::"Create Common Posting Setup");
        Codeunit.Run(Codeunit::"Create Common Location");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Common Customer/Vendor");
        Codeunit.Run(Codeunit::"Create Common Item Tracking");
    end;

    procedure CreateTransactionalData()
    begin
        exit;
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}