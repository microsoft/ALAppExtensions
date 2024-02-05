namespace Microsoft.Sustainability.Journal;

enum 6213 "Sustainability Jnl. Doc. Type"
{
    Access = Public;
    Caption = 'Sustainability Journal Document Type';
    Extensible = false;

    value(0; " ") { Caption = ' '; }
    value(1; "Invoice") { Caption = 'Invoice'; }
    value(2; "Credit Memo") { Caption = 'Credit Memo'; }
}