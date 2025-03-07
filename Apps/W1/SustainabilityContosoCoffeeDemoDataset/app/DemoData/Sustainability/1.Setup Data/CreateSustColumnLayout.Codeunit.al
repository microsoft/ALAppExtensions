codeunit 5247 "Create Sust. Column Layout"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(ESGPERIODColumnName(), ESGDescLbl);
        ContosoAccountSchedule.InsertColumnLayout(ESGPERIODColumnName(), 10000, '10', CurrentPeriodLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ESGPERIODColumnName(), 20000, '10', PeriodMinus1Lbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, InsertPeriodFormula(-1), false);
        ContosoAccountSchedule.InsertColumnLayout(ESGPERIODColumnName(), 30000, '10', PeriodMinus2Lbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, InsertPeriodFormula(-2), false);
    end;

    procedure ESGPERIODColumnName(): Code[10]
    begin
        exit(ESGPERIODTok);
    end;

    local procedure InsertPeriodFormula(Period: Integer): Text[10]
    var
        ColumnLayout: Record "Column Layout";
    begin
        exit(StrSubstNo('%1%2', Period, ColumnLayout.GetPeriodName()));
    end;

    var
        ESGPERIODTok: Label 'ESG-PERIOD', MaxLength = 10, Locked = true;
        ESGDescLbl: Label 'ESG Periods', MaxLength = 80;
        CurrentPeriodLbl: Label 'Current Period';
        PeriodMinus1Lbl: Label 'Current Period - 1';
        PeriodMinus2Lbl: Label 'Current Period - 2';
}