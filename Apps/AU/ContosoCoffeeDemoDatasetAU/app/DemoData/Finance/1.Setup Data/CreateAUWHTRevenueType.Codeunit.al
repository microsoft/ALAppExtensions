codeunit 17153 "Create AU WHT Revenue Type"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAUWHT: Codeunit "Contoso AU WHT";
    begin
        ContosoAUWHT.SetOverwriteData(true);
        ContosoAUWHT.InsertWHTRevenueType(Wht(), WithHoldingTaxLbl, 1);
        ContosoAUWHT.SetOverwriteData(false);
    end;

    procedure Wht(): Code[10]
    begin
        exit(WhtTok);
    end;

    var
        WhtTok: Label 'WHT', MaxLength = 10, Locked = true;
        WithHoldingTaxLbl: Label 'Withholding Tax', MaxLength = 50;
}