namespace Microsoft.Finance.GeneralLedger.Review;

table 22216 "G/L Entry Review Entry"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Use "G/L Entry Review Log" instead.';
    ObsoleteTag = '27.0';
    fields
    {
        field(1; "G/L Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Reviewed Identifier"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Reviewed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Reviewed Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(GLEntryNo; "G/L Entry No.")
        {
            Unique = false;
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        GLEntryReviewLog: Record "G/L Entry Review Log";
    begin
        GLEntryReviewLog.Init();
        GLEntryReviewLog."G/L Entry No." := "G/L Entry No.";
        GLEntryReviewLog."Reviewed Identifier" := "Reviewed Identifier";
        GLEntryReviewLog."Reviewed By" := "Reviewed By";
        GLEntryReviewLog."Reviewed Amount" := "Reviewed Amount";
        GLEntryReviewLog.Insert(true);
    end;

    trigger OnDelete()
    var
        GLEntryReviewLog: Record "G/L Entry Review Log";
    begin
        GLEntryReviewLog.SetRange("G/L Entry No.", "G/L Entry No.");
        if GLEntryReviewLog.FindSet() then
            repeat
                GLEntryReviewLog.Delete(true);
            until GLEntryReviewLog.Next() = 0;
    end;
}