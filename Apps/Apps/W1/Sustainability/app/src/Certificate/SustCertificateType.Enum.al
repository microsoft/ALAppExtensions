namespace Microsoft.Sustainability.Certificate;

enum 6215 "Sust. Certificate Type"
{
    Extensible = true;
    Caption = 'Sust. Certificate Type';

    value(0; Vendor)
    {
        Caption = 'Vendor';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
}