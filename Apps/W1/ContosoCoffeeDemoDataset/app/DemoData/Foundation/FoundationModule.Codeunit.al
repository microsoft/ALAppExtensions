codeunit 5203 "Foundation Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        exit;
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
    end;

    procedure CreateSetupData()
    var
    begin
        Codeunit.Run(Codeunit::"Create Shipping Data");
        Codeunit.Run(Codeunit::"Create Language");
        Codeunit.Run(Codeunit::"Create Unit of Measure");
        Codeunit.Run(Codeunit::"Create Country/Region");
        Codeunit.Run(Codeunit::"Create Doc Sending Profile");
        Codeunit.Run(Codeunit::"Create Company Information");
        Codeunit.Run(Codeunit::"Create Payment Terms");
        Codeunit.Run(Codeunit::"Create Job Queue Category");
        Codeunit.Run(Codeunit::"Create Accounting Period");
        Codeunit.Run(Codeunit::"Create No. Series");
        Codeunit.Run(Codeunit::"Create Notification Setup");
        Codeunit.Run(Codeunit::"Create Cue Setup");
        Codeunit.Run(Codeunit::"Create Post Code");
        Codeunit.Run(Codeunit::"Create Named Forward Link");
        Codeunit.Run(Codeunit::"Create Data Exchange");
        Codeunit.Run(Codeunit::"Create Data Exchange Type");
        Codeunit.Run(Codeunit::"Create Custom Report Layout");
        Codeunit.Run(Codeunit::"Create O365 Template");
        // Codeunit.Run(Codeunit::"Create Excel Template");
    end;

    procedure CreateMasterData()
    begin
        exit;
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
