namespace Microsoft.Sustainability.Journal;

enum 6213 "Sustainability Jnl. Doc. Type"
{
    Access = Public;
    Caption = 'Sustainability Journal Document Type';
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Invoice") { Caption = 'Invoice'; }
    value(2; "Credit Memo") { Caption = 'Credit Memo'; }
    value(3; "GHG Credit") { Caption = 'GHG Credit'; }
}