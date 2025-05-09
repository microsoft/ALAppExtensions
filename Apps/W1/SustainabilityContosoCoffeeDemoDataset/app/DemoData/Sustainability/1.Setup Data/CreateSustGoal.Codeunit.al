#pragma warning disable AA0247
codeunit 5249 "Create Sust. Goal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtility: Codeunit "Contoso Utilities";
        ContosoScorecard: Codeunit "Create Sust. Scorecard";
        ContosoSustainability: Codeunit "Contoso Sustainability";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoSustainability.InsertGoal(ContosoScorecard.Main(), Quarter(), QuarterLbl, ContosoUtility.AdjustDate(19030101D), ContosoUtility.AdjustDate(19030331D), ContosoUtility.AdjustDate(19030401D), ContosoUtility.AdjustDate(19030630D), CreateUnitOfMeasure.KG(), '', '', 10000, 500, 55, 12500, 10000, true);
        ContosoSustainability.InsertGoal(ContosoScorecard.Main(), Year(), YearLbl, ContosoUtility.AdjustDate(19030101D), ContosoUtility.AdjustDate(19031231D), ContosoUtility.AdjustDate(19040101D), ContosoUtility.AdjustDate(19041231D), CreateUnitOfMeasure.KG(), '', '', 2100, 84, 7.5, false);
    end;

    procedure Quarter(): Code[20]
    begin
        exit(QuarterTok);
    end;

    procedure Year(): Code[20]
    begin
        exit(YearTok);
    end;

    var
        QuarterTok: Label 'QUARTER', MaxLength = 20;
        YearTok: Label 'YEAR', MaxLength = 20;
        QuarterLbl: Label 'Quarterly Goal 2024Q2', MaxLength = 100;
        YearLbl: Label 'Yearly Goal 2024', MaxLength = 100;
}
