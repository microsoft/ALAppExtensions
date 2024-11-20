codeunit 5373 "E-Document Contoso Module" implements "Contoso Demo Data Module"
{

    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"E-Document Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Warehouse Module");
    end;

    procedure CreateSetupData()
    begin
        // Codeunit.Run(Codeunit::"Create E-Document Setup");
    end;

    procedure CreateMasterData()
    // var
        // EDocumentModuleSetup: Record "E-Document Module Setup";
    begin
        // EDocumentModuleSetup.InitEDocumentModuleSetup();
        // Codeunit.Run(Codeunit::"Create E-Document Master Data");
    end;

    procedure CreateTransactionalData()
    begin
        // Codeunit.Run(Codeunit::"Create E-Document Transactions");
    end;

    procedure CreateHistoricalData()
    begin

    end;
}