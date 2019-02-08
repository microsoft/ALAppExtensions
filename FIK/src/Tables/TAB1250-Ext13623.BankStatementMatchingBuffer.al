tableextension 13623 BankStatementMatchingBuffer extends "Bank Statement Matching Buffer"
{
    fields
    {
        field(13652; MatchStatus; Option)
        {
            OptionMembers = " ",NoMatch,Duplicate,IsPaid,Partial,Extra,Fully;
            Caption = 'Match Status';
            DataClassification = SystemMetadata;
        }
        field(13653; DescriptionBankStatment; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }
}