tableextension 1952 CustomerLedgerEntryLPP extends "Cust. Ledger Entry"
{
    fields
    {
        field(1300; "Payment Prediction"; Option)
        {
            OptionMembers = " ",Late,"On-Time";
            OptionCaption = ' ,Late,On-Time';
        }
        field(1301; "Prediction Confidence"; Option)
        {
            OptionMembers = " ",Low,Medium,High;
            OptionCaption = ' ,Low,Medium,High';
            Caption = 'Prediction Confidence';
        }
        field(1302; "Prediction Confidence %"; Decimal)
        {
        }
    }
}