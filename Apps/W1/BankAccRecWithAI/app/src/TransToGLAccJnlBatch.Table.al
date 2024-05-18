namespace Microsoft.Bank.Reconciliation;

using Microsoft.Finance.GeneralLedger.Journal;

table 7252 "Trans. to G/L Acc. Jnl. Batch"
{
    Extensible = false;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(50; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(51; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}