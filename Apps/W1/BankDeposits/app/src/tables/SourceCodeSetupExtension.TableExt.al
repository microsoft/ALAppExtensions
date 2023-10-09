namespace Microsoft.Bank.Deposit;

using Microsoft.Foundation.AuditCodes;

tableextension 1695 SourceCodeSetupExtension extends "Source Code Setup"
{
    fields
    {
        field(1690; "Bank Deposit"; Code[10])
        {
            Caption = 'Bank Deposit';
            TableRelation = "Source Code";
            DataClassification = SystemMetadata;
        }
    }
}