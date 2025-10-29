namespace Microsoft.Sustainability.Codes;

enum 6239 "Product Classification Type"
{
    Extensible = true;
    Caption = 'Product Classification Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; UNSPSC)
    {
        Caption = 'UNSPSC - UN Standard Products and Services Code';
    }
}