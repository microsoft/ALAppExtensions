codeunit 4760 "Create Mfg Availability Setup"
{
    Permissions = tabledata "Company Information" = rm;

    trigger OnRun()
    begin
        ModifyData('<90D>', Enum::"Analysis Period Type"::Week);
    end;

    var
        CompanyInformation: Record "Company Information";

    local procedure ModifyData(AvailPeriodCalc: Code[10]; AvailTimeBucket: Enum "Analysis Period Type")
    begin
        CompanyInformation.Get();
        Evaluate(CompanyInformation."Check-Avail. Period Calc.", AvailPeriodCalc);
        CompanyInformation.Validate("Check-Avail. Period Calc.");
        CompanyInformation.Validate("Check-Avail. Time Bucket", AvailTimeBucket);
        CompanyInformation.Modify();
    end;
}

