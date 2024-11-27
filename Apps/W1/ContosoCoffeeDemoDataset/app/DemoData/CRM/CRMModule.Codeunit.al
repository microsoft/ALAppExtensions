codeunit 5481 "CRM Module" implements "Contoso Demo Data Module"
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
    begin
        Codeunit.Run(Codeunit::"Create Dup. Search Str. Setup");
        Codeunit.Run(Codeunit::"Create Interaction Group");
        Codeunit.Run(Codeunit::"Create Interaction Template");
        Codeunit.Run(Codeunit::"Create Business Relation");
        Codeunit.Run(Codeunit::"Create Sales Cycle");
        Codeunit.Run(Codeunit::"Create Salutations");
        Codeunit.Run(Codeunit::"Create Marketing Setup");
        Codeunit.Run(Codeunit::"Create Word Template");
        Codeunit.Run(Codeunit::"Create CRM Dimension");
        Codeunit.Run(Codeunit::"Create Campaign Status");
        Codeunit.Run(Codeunit::"Create Organizational Level");
        Codeunit.Run(Codeunit::"Create Team");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Activity");
        Codeunit.Run(Codeunit::"Create Activity Step");
        Codeunit.Run(Codeunit::"Create Salesperson/Purchaser");
        Codeunit.Run(Codeunit::"Create Campaign");
        Codeunit.Run(Codeunit::"Create Close Opportunity Code");
        Codeunit.Run(Codeunit::"Create Industry Group");
        Codeunit.Run(Codeunit::"Create Job Responsibility");
        Codeunit.Run(Codeunit::"Create Mailing Group");
        Codeunit.Run(Codeunit::"Create CRM Dimension Value");
        Codeunit.Run(Codeunit::"Create Sales Cycle Stage");
        Codeunit.Run(Codeunit::"Create Salutation Formula");
        Codeunit.Run(Codeunit::"Create Web Source");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Segment");
        Codeunit.Run(Codeunit::"Create Opportunity");
        Codeunit.Run(Codeunit::"Create Profile Questionnaire");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Interaction Log Entry");
    end;
}