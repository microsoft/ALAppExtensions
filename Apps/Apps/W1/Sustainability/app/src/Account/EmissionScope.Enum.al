namespace Microsoft.Sustainability.Account;

enum 6212 "Emission Scope"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Scope 1") { Caption = 'Scope 1'; }
    value(2; "Scope 2") { Caption = 'Scope 2'; }
    value(3; "Scope 3") { Caption = 'Scope 3'; }
    value(4; "Water/Waste") { Caption = 'Water/Waste'; }
    value(5; "Out of Scope") { Caption = 'Out of Scope'; }
}
