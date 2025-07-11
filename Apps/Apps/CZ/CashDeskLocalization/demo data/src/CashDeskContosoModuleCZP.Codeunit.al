#pragma warning disable AA0247
codeunit 31339 "Cash Desk Contoso Module CZP" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Finance);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Gen. Ledger Setup CZP");
        Codeunit.Run(Codeunit::"Create Rounding Method CZP");
        Codeunit.Run(Codeunit::"Create Curr. Nominal Value CZP");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Cash Desk CZP");
        Codeunit.Run(Codeunit::"Create Cash Desk Event CZP");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Cash Document CZP");
    end;

    procedure CreateHistoricalData()
    var
        CreateCashDocumentCZP: Codeunit "Create Cash Document CZP";
    begin
        CreateCashDocumentCZP.ReleaseCashDocuments();
        CreateCashDocumentCZP.PostCashDocuments();
    end;
}
