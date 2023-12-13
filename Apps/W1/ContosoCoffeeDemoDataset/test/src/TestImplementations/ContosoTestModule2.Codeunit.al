codeunit 148047 "Contoso Test Module 2" implements "Contoso Demo Data Module"
{
    procedure RunConfigurationPage();
    begin

    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Contoso Test 1");
    end;

    procedure CreateSetupData();
    begin

    end;

    procedure CreateMasterData();
    begin

    end;

    procedure CreateTransactionalData();
    begin

    end;

    procedure CreateHistoricalData();
    begin

    end;
}