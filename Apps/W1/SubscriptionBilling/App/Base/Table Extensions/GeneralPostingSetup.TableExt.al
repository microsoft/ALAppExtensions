namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Account;

tableextension 8066 "General Posting Setup" extends "General Posting Setup"
{
    fields
    {
        field(8051; "Customer Contract Account"; Code[20])
        {
            Caption = 'Customer Contract Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8052; "Cust. Contr. Deferral Account"; Code[20])
        {
            Caption = 'Customer Contract Deferral Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8053; "Vendor Contract Account"; Code[20])
        {
            Caption = 'Vendor Contract Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(8054; "Vend. Contr. Deferral Account"; Code[20])
        {
            Caption = 'Vendor Contract Deferral Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
    }
}
