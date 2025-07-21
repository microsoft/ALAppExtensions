#pragma warning disable AA0247
tableextension 6162 "E-Doc. Purch. Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(6100; "E-Document Matching Difference"; Decimal)
        {
            Caption = 'E-Document Matching Difference %';
            InitValue = 0;
            DecimalPlaces = 1;
        }
        field(6101; "E-Document Learn Copilot Matchings"; Boolean)
        {
            Caption = 'E-Document Learn Copilot Matchings';
        }
    }
}
