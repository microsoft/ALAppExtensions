namespace Microsoft.SubscriptionBilling.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36961 "Setup - Subscription Billing" extends "PowerBI Reports Setup"
{
    fields
    {
        field(37000; "Subs. Billing Report Name"; Text[200])
        {
            Caption = 'Subscription Billing Report Name';
            DataClassification = CustomerContent;
        }
        field(37001; "Subscription Billing Report Id"; Guid)
        {
            Caption = 'Subscription Billing Report Id';
            DataClassification = CustomerContent;
        }
    }
}