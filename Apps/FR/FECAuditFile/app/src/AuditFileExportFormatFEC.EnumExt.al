enumextension 10826 "Audit File Export Format FEC" extends "Audit File Export Format"
{
    value(10826; FEC)
    {
        Caption = 'FEC';
        Implementation = "Audit File Export Data Handling" = "Data Handling FEC",
                         "Audit File Export Data Check" = "Data Check FEC";
    }
}