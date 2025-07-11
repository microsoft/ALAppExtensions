namespace Microsoft.Bank.Deposit;

using Microsoft.Sales.Setup;
using Microsoft.Foundation.NoSeries;

tableextension 1694 SalesReceivablesSetupExtension extends "Sales & Receivables Setup"
{
    fields
    {
        field(1690; "Bank Deposit Nos."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Bank Deposit Nos.';
            TableRelation = "No. Series";
        }
        field(1691; "Post Bank Deposits as Lump Sum"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Post Bank Deposits as Lump Sum';
        }
    }
}