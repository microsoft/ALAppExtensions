namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.ExtendedText;

tableextension 31071 "Extended Text Header CZP" extends "Extended Text Header"
{
    fields
    {
        field(11740; "Cash Desk CZP"; Boolean)
        {
            Caption = 'Cash Desk';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the text will be available in cash documents.';
        }
    }
}
