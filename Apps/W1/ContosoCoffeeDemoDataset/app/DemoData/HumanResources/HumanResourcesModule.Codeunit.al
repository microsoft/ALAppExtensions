codeunit 5168 "Human Resources Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Human Resources Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    var
        HumanResourcesModuleSetup: Record "Human Resources Module Setup";
    begin
        HumanResourcesModuleSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Human Resources UoM");
        Codeunit.Run(Codeunit::"Create Causes of Absence");
        Codeunit.Run(Codeunit::"Create HR GL Account");
        Codeunit.Run(Codeunit::"Create Employee Posting Group");
        Codeunit.Run(Codeunit::"Create Relatives");
        Codeunit.Run(Codeunit::"Create Employee No Series");
        Codeunit.Run(Codeunit::"Create Human Resources Setup");
        Codeunit.Run(Codeunit::"Create Grounds for Termination");
        Codeunit.Run(Codeunit::"Create Misc. Article");
        Codeunit.Run(Codeunit::"Create Confidential");
        Codeunit.Run(Codeunit::"Create Employee Stat. Group");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Qualification");
        Codeunit.Run(Codeunit::"Create Union");
        Codeunit.Run(Codeunit::"Create Employment Contract");
        Codeunit.Run(Codeunit::"Create Employee");
        Codeunit.Run(Codeunit::"Create Employee Template");
        Codeunit.Run(Codeunit::"Create Employee Absence");
        Codeunit.Run(Codeunit::"Create Employee Qualification");
        Codeunit.Run(Codeunit::"Create Employee Relative");
        Codeunit.Run(Codeunit::"Create Misc. Article Info.");
        Codeunit.Run(Codeunit::"Create Confidential Info.");
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