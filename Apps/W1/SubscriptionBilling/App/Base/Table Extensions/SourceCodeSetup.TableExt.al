namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.AuditCodes;

tableextension 8069 "Source Code Setup" extends "Source Code Setup"
{
    fields
    {
        field(8051; "Sub. Contr. Deferrals Release"; Code[10])
        {
            Caption = 'Subscription Contract Deferrals Release';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}
