namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.Analysis;

tableextension 2625 StatAccAnalysisView extends "Analysis View"
{
    fields
    {
        field(2625; "Statistical Account Filter"; Code[250])
        {
            Caption = 'Statistical Account Filter';
            TableRelation = "Statistical Account";
            DataClassification = SystemMetadata;

            trigger OnLookup()
            var
                StatisticalAccountList: Page "Statistical Account List";
                AccountFilter: Text;
            begin
                StatisticalAccountList.LookupMode(true);
                if StatisticalAccountList.RunModal() = ACTION::LookupOK then
                    AccountFilter := StatisticalAccountList.GetSelectionFilter();

                Rec.Validate("Statistical Account Filter", AccountFilter);
            end;

            trigger OnValidate()
            begin
                UpdateStatisticalAccountFilter(xRec."Statistical Account Filter", Rec."Statistical Account Filter");
            end;
        }
    }

    internal procedure UpdateStatisticalAccountFilter(xRecStatisticalAccountFilter: Code[250]; RecStatisticalAccountFilter: Code[250])
    var
        AnalysisViewEntry: Record "Analysis View Entry";
        StatisticalAccount: Record "Statistical Account";
        DeleteConfirmed: Boolean;
    begin
        if (Rec."Last Entry No." <> 0) and (xRecStatisticalAccountFilter = '') and (RecStatisticalAccountFilter <> '') then begin
            DeleteConfirmed := ConfirmDeleteChanges();
            if not DeleteConfirmed then
                Error('');

            StatisticalAccount.SetFilter("No.", Rec."Statistical Account Filter");
            if StatisticalAccount.Find('-') then
                repeat
                    StatisticalAccount.Mark := true;
                until StatisticalAccount.Next() = 0;
            StatisticalAccount.SetRange("No.");
            if StatisticalAccount.Find('-') then
                repeat
                    if not StatisticalAccount.Mark() then begin
                        AnalysisViewEntry.SetRange("Analysis View Code", Rec.Code);
                        AnalysisViewEntry.SetRange("Account No.", StatisticalAccount."No.");
                        AnalysisViewEntry.DeleteAll();
                    end;
                until StatisticalAccount.Next() = 0;
        end;
        if (Rec."Last Entry No." <> 0) and (RecStatisticalAccountFilter <> xRecStatisticalAccountFilter) and (xRecStatisticalAccountFilter <> '')
        then begin
            if not DeleteConfirmed then
                DeleteConfirmed := ConfirmDeleteChanges();
            if not DeleteConfirmed then
                Error('');

            Rec.AnalysisViewReset();
        end
    end;

    local procedure ConfirmDeleteChanges(): Boolean
    begin
        if not GuiAllowed() then
            exit(true);

        exit(Confirm(UpdateOfAnalysisViewNeededQst, true));
    end;

    var
        UpdateOfAnalysisViewNeededQst: Label 'Changing the setup values will delete the existing entries.\\You will have to update again.\\Do you want to continue?';
}