namespace Microsoft.Sustainability.Account;

enum 6211 "Sustainability Account Type"
{
    Extensible = false;

    value(0; Posting) { Caption = 'Posting'; }
    value(1; Heading) { Caption = 'Heading'; }
    value(2; Total) { Caption = 'Total'; }
    value(3; "Begin-Total") { Caption = 'Begin-Total'; }
    value(4; "End-Total") { Caption = 'End-Total'; }
}