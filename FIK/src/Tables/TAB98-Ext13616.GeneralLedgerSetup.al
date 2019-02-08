tableextension 13616 GeneralLedgerSetup extends "General Ledger Setup"
{
    fields
    {
        field(13652; "FIK Import Format"; code[20])
        {
            Caption = 'FIK Import Format';
            TableRelation = "Data Exch. Def" WHERE (Type = CONST ("Bank Statement Import"));
        }
    }
}