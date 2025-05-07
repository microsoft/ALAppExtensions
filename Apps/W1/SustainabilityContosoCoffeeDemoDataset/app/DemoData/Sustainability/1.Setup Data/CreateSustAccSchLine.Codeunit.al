#pragma warning disable AA0247
codeunit 5244 "Create Sust. Acc. Sch. Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccSchName: Codeunit "Create Sust. Acc. Sch. Name";
        ContosoSustainabilityAccount: Codeunit "Create Sustainability Account";
        ContosoStatisticalAccount: Codeunit "Create Statistical Account";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 10000, '10', EnvironmentalDataLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 20000, '20', Scope1EmissionsLbl, ContosoSustainabilityAccount.Scope1() + '..' + ContosoSustainabilityAccount.TotalScope1(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 30000, '30', Scope2EmissionsLbl, ContosoSustainabilityAccount.Scope2() + '..' + ContosoSustainabilityAccount.TotalScope2(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 40000, '40', Scope3EmissionsLbl, ContosoSustainabilityAccount.Scope3() + '..' + ContosoSustainabilityAccount.TotalScope3(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 50000, '50', CarbonCreditScope1Lbl, ContosoSustainabilityAccount.CarbonCreditScope1(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 60000, '60', CarbonCreditScope2Lbl, ContosoSustainabilityAccount.CarbonCreditScope2(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 70000, '70', CarbonCreditScope3Lbl, ContosoSustainabilityAccount.CarbonCreditScope3(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0, Enum::"Account Schedule Amount Type"::CO2e);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 80000, '80', TotalEmissionScope1Lbl, '20+50', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 90000, '90', TotalEmissionScope2Lbl, '30+60', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 100000, '100', TotalEmissionScope3Lbl, '40+70', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 110000, '110', TotalEmissionLbl, '80+90+100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 120000, '120', TotalInternalEmissionFeeLbl, ContosoSustainabilityAccount.GasEmissions() + '..' + ContosoSustainabilityAccount.TotalGasEmissions(), Enum::"Acc. Schedule Line Totaling Type"::"Sust. Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true, false, false, 0, Enum::"Account Schedule Amount Type"::"Carbon Fee");
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 130000, '130', SocialDataLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 140000, '140', EmployeeDiversityGenderFemaleLbl, ContosoStatisticalAccount.DivGenFemale(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 150000, '150', EmployeeDiversityGenderMaleLbl, ContosoStatisticalAccount.DivGenMale(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 160000, '160', EmployeeDiversityAgedUnder25Lbl, ContosoStatisticalAccount.DivAge25(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 170000, '170', EmployeeDiversityAged25to40Lbl, ContosoStatisticalAccount.DivAge40(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 180000, '180', EmployeeDiversityAged40to55Lbl, ContosoStatisticalAccount.DivAge55(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 190000, '190', EmployeeDiversityAgedOver55Lbl, ContosoStatisticalAccount.DivAge55Plus(), Enum::"Acc. Schedule Line Totaling Type"::"Statistical Account", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 200000, '200', TOTALNumberofEmployeesLbl, '140+150', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, true, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(ContosoAccSchName.ESG(), 210000, '210', TotalEmissionPerEmployeeLbl, '110/200', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, true, false, false, 0);
    end;

    var
        EnvironmentalDataLbl: Label 'Environmental Data', MaxLength = 80;
        Scope1EmissionsLbl: Label 'Scope 1 Emissions', MaxLength = 80;
        Scope2EmissionsLbl: Label 'Scope 2 Emissions', MaxLength = 80;
        Scope3EmissionsLbl: Label 'Scope 3 Emissions', MaxLength = 80;
        CarbonCreditScope1Lbl: Label 'Carbon Credit - Scope 1', MaxLength = 80;
        CarbonCreditScope2Lbl: Label 'Carbon Credit - Scope 2', MaxLength = 80;
        CarbonCreditScope3Lbl: Label 'Carbon Credit - Scope 3', MaxLength = 80;
        TotalEmissionScope1Lbl: Label 'TOTAL EMISSION - Scope 1', MaxLength = 80;
        TotalEmissionScope2Lbl: Label 'TOTAL EMISSION - Scope 2', MaxLength = 80;
        TotalEmissionScope3Lbl: Label 'TOTAL EMISSION - Scope 3', MaxLength = 80;
        TotalEmissionLbl: Label 'TOTAL EMISSION', MaxLength = 80;
        TotalInternalEmissionFeeLbl: Label 'TOTAL Internal Emission Fee', MaxLength = 80;
        SocialDataLbl: Label 'Social Data', MaxLength = 80;
        EmployeeDiversityGenderFemaleLbl: Label 'Employee Diversity Gender - Female', MaxLength = 80;
        EmployeeDiversityGenderMaleLbl: Label 'Employee Diversity Gender - Male', MaxLength = 80;
        EmployeeDiversityAgedUnder25Lbl: Label 'Employee Diversity: Aged under 25', MaxLength = 80;
        EmployeeDiversityAged25to40Lbl: Label 'Employee Diversity: Aged 25 to 40', MaxLength = 80;
        EmployeeDiversityAged40to55Lbl: Label 'Employee Diversity: Aged 40 to 55', MaxLength = 80;
        EmployeeDiversityAgedOver55Lbl: Label 'Employee Diversity: Aged over 55', MaxLength = 80;
        TOTALNumberofEmployeesLbl: Label 'TOTAL Number of Employees', MaxLength = 80;
        TotalEmissionPerEmployeeLbl: Label 'Total Emission per Employee', MaxLength = 80;
}
