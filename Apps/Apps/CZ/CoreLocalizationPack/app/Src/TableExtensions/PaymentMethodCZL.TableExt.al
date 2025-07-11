namespace Microsoft.Bank.BankAccount;

tableextension 31058 "Payment Method CZL" extends "Payment Method"
{
    fields
    {
        field(11782; "Print QR Payment CZL"; Boolean)
        {
            Caption = 'Print QR payment';
            DataClassification = CustomerContent;
        }
    }
}
