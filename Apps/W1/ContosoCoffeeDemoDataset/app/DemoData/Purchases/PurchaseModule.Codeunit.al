codeunit 5394 "Purchase Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    procedure RunConfigurationPage()
    begin
        exit;
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Finance");
        Dependencies.Add(Enum::"Contoso Demo Data Module"::CRM);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Inventory);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(codeunit::"Create Purchase Payable Setup");
        Codeunit.Run(codeunit::"Create Vendor Posting Group");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(codeunit::"Create Over-Receipt Code");
        Codeunit.Run(codeunit::"Create Vendor");
        Codeunit.Run(codeunit::"Create Vendor Bank Account");
        Codeunit.Run(codeunit::"Create Vendor Template");
        Codeunit.Run(codeunit::"Create Purchase Dim. Value");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Purchase Document");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Posted Purchase Data");
        Codeunit.Run(Codeunit::"Post Transfer Data");
    end;
}