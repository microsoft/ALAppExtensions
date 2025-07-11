namespace Microsoft.Finance.Latepayment;

using Microsoft.Sales.Receivables;
tableextension 1952 CustomerLedgerEntryLPP extends "Cust. Ledger Entry"
{
    fields
    {
        field(1300; "Payment Prediction"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",Late,"On-Time";
            OptionCaption = ' ,Late,On-Time';
        }
        field(1301; "Prediction Confidence"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",Low,Medium,High;
            OptionCaption = ' ,Low,Medium,High';
            Caption = 'Prediction Confidence';
        }
        field(1302; "Prediction Confidence %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Prediction Confidence %';
        }
    }
}