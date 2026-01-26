#if not CLEANSCHEMA27
namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;

table 22216 "G/L Entry Review Entry"
{
    ObsoleteReason = 'Use "G/L Entry Review Log" instead.';
#if not CLEAN27
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '30.0';
#endif

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
        GlEntry: Record "G/L Entry";
    begin
        GLEntryReviewLog.Init();
        GLEntryReviewLog."G/L Entry No." := "G/L Entry No.";
        GLEntryReviewLog."Reviewed Identifier" := "Reviewed Identifier";
        GLEntryReviewLog."Reviewed By" := "Reviewed By";
        if GlEntry.Get("G/L Entry No.") then begin
            GLEntryReviewLog."G/L Account No." := GlEntry."G/L Account No.";
            GLEntryReviewLog."Reviewed Amount" := GlEntry.Amount;
        end;
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
#endif