table 2630 "Statistical Acc. Journal Batch"
{
    Caption = 'Statistical Account Journal Batch';
    DataCaptionFields = "Name";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Statistical Account No."; Code[20])
        {
            Caption = 'Statistical Account No.';
            DataClassification = CustomerContent;
            TableRelation = "Statistical Account";
        }
        field(50; "Statistical Account Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Statistical Account".Name where("No." = field("Statistical Account No.")));
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Name")
        {
            Clustered = true;
        }
    }
    internal procedure CreateDefaultBatch()
    var
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
    begin
        StatisticalAccJournalBatch.Name := DefaultBatchNameTxt;
        StatisticalAccJournalBatch.Description := DefaultBatchDescriptionTxt;
        StatisticalAccJournalBatch.Insert();
    end;

    var
        DefaultBatchNameTxt: Label 'DEFAULT', Comment = 'Maximum length of this string is 10 characters.';
        DefaultBatchDescriptionTxt: Label 'Default Batch';
}