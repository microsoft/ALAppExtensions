codeunit 10516 "Create GB Column Layout"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGBAccountSchedule: Codeunit "Contoso GB Account Schedule";
        CreateGBColumnLayoutName: Codeunit "Create GB Column Layout Name";
    begin
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceBudget(), 10000, 'N', BalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceBudget(), 20000, 'B', BudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceBudget(), 30000, '', VarianceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", 'N-B', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceBudget(), 40000, '', VariancePercentageLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '100*(N/B-1)', false, Enum::"Column Layout Show"::Always, '', '');

        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceLastYear(), 10000, 'N', BalanceThisYearLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceLastYear(), 20000, 'L', BalanceLastYearLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', false, Enum::"Column Layout Show"::Always, '', '<-1Y>');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceLastYear(), 30000, '', VarianceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", 'N-L', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.BalanceLastYear(), 40000, '', VariancePercentageLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '100*(N/L-1)', false, Enum::"Column Layout Show"::Always, '', '');

        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeBudget(), 10000, 'N', NetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', true, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeBudget(), 20000, 'B', BudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", Enum::"Account Schedule Amount Type"::"Net Amount", '', true, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeBudget(), 30000, '', VarianceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", 'B-N', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeBudget(), 40000, '', VariancePercentageLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '100*(N/B-1)', false, Enum::"Column Layout Show"::Always, '', '');

        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeLastYear(), 10000, 'N', NetChangeThisYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', true, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeLastYear(), 20000, 'L', NetChangeLastYearLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '', true, Enum::"Column Layout Show"::Always, '', '<-1Y>');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeLastYear(), 30000, '', VarianceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", 'L-N', false, Enum::"Column Layout Show"::Always, '', '');
        ContosoGBAccountSchedule.InsertColumnLayout(CreateGBColumnLayoutName.NetChangeLastYear(), 40000, '', VariancePercentageLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Net Amount", '100*(N/L-1)', false, Enum::"Column Layout Show"::Always, '', '');
    end;

    var
        BalanceLbl: Label 'Balance', MaxLength = 30;
        BudgetLbl: Label 'Budget', MaxLength = 30;
        VarianceLbl: Label 'Variance', MaxLength = 30;
        VariancePercentageLbl: Label 'Variance%', MaxLength = 30;
        BalanceThisYearLbl: Label 'Balance This Year', MaxLength = 30;
        BalanceLastYearLbl: Label 'Balance Last Year', MaxLength = 30;
        NetChangeLbl: Label 'Net Change', MaxLength = 30;
        NetChangeThisYearLbl: Label 'Net Change This Year', MaxLength = 30;
        NetChangeLastYearLbl: Label 'Net Change Last Year', MaxLength = 30;
}