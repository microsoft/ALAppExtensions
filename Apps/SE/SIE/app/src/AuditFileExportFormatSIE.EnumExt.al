enumextension 5315 "Audit File Export Format SIE" extends "Audit File Export Format"
{
    value(5315; SIE)
    {
        Caption = 'SIE';
        Implementation = "Audit File Export Data Handling" = "Data Handling SIE",
                         "Audit File Export Data Check" = "Data Check SIE";
    }
}