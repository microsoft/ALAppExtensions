codeunit 5415 "Finance Module" implements "Contoso Demo Data Module"
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
    end;

    procedure CreateSetupData()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        Codeunit.Run(Codeunit::"Create VAT Posting Groups");
        Codeunit.Run(Codeunit::"Create Posting Groups");
        Codeunit.Run(Codeunit::"Create G/L Account");
        CreatePostingGroups.UpdateGenPostingSetup();
        CreateVATPostingGroups.UpdateVATPostingSetup();
        Codeunit.Run(Codeunit::"Create Dimension");
        Codeunit.Run(Codeunit::"Create KPI Web Srv Setup");
        Codeunit.Run(Codeunit::"Create Analysis View");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Name");
        Codeunit.Run(Codeunit::"Create KPI Web Srv Line");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Line");
        Codeunit.Run(Codeunit::"Create Column Layout Name");
        Codeunit.Run(Codeunit::"Create Acc. Schedule Chart");
        Codeunit.Run(Codeunit::"Create Chart Definition");
        Codeunit.Run(Codeunit::"Create Currency");
        Codeunit.Run(Codeunit::"Create General Ledger Setup");
        Codeunit.Run(Codeunit::"Create Gen. Journal Template");
        Codeunit.Run(Codeunit::"Create Gen. Journal Batch");
        Codeunit.Run(Codeunit::"Create Resources Setup");
        Codeunit.Run(Codeunit::"Create VAT Reg. No. Format");
        Codeunit.Run(Codeunit::"Create VAT Setup Posting Grp.");
        Codeunit.Run(Codeunit::"Create VAT Report Setup");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Dimension Value");
        Codeunit.Run(Codeunit::"Create Column Layout");
        Codeunit.Run(Codeunit::"Create Financial Report");
        Codeunit.Run(Codeunit::"Create Acc. Sched. Chart Line");
        Codeunit.Run(Codeunit::"Categ. Generate Acc. Schedules");
        Codeunit.Run(Codeunit::"Create Currency Exchange Rate");
        Codeunit.Run(Codeunit::"Create Resource");
        Codeunit.Run(Codeunit::"Create VAT Statement");
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