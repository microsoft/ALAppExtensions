tableextension 31285 "Gen. Journal Line CZB" extends "Gen. Journal Line"
{
    fields
    {
        field(11710; "Search Rule Code CZB"; Code[10])
        {
            Caption = 'Search Rule Code';
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11711; "Search Rule Line No. CZB"; Integer)
        {
            Caption = 'Search Rule Line Code';
            TableRelation = "Search Rule Line CZB"."Line No." where("Search Rule Code" = field("Search Rule Code CZB"));
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GeneralLedgerSetupRead: Boolean;

    procedure IsLocalCurrencyCZB(): Boolean
    begin
        ReadGeneralLedgerSetupCZB();
        exit(("Currency Code" = '') or ("Currency Code" = GeneralLedgerSetup."LCY Code"));
    end;

    local procedure ReadGeneralLedgerSetupCZB()
    begin
        if not GeneralLedgerSetupRead then begin
            GeneralLedgerSetup.Get();
            GeneralLedgerSetupRead := true;
        end;
    end;
}
