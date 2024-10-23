namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.AuditCodes;

tableextension 8069 "Source Code Setup" extends "Source Code Setup"
{
    fields
    {
        field(8051; "Contract Deferrals Release"; Code[10])
        {
            Caption = 'Contract Deferrals Release';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}
