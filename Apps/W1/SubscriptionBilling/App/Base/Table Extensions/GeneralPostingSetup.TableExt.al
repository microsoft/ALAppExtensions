namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Account;

tableextension 8066 "General Posting Setup" extends "General Posting Setup"
{
    fields
    {
        field(8051; "Cust. Sub. Contract Account"; Code[20])
        {
            Caption = 'Customer Subscription Contract Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8052; "Cust. Sub. Contr. Def Account"; Code[20])
        {
            Caption = 'Customer Subscription Contract Deferral Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8053; "Vend. Sub. Contract Account"; Code[20])
        {
            Caption = 'Vendor Subscription Contract Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8054; "Vend. Sub. Contr. Def. Account"; Code[20])
        {
            Caption = 'Vendor Subscription Contract Deferral Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
    }
}
