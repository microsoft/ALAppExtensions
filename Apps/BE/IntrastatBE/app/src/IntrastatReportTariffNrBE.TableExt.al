tableextension 11348 "Intrastat Report Tariff Nr. BE" extends "Tariff Number"
{
    fields
    {
        modify("Suppl. Conversion Factor")
        {
            trigger OnBeforeValidate()
            begin
                SetSkipValidationLogic(true);
            end;
        }
        modify("Suppl. Unit of Measure")
        {
            trigger OnBeforeValidate()
            begin
                SetSkipValidationLogic(true);
            end;
        }
    }
}