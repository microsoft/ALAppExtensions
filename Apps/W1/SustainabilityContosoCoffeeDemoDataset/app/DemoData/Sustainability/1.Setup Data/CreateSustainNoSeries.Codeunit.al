#pragma warning disable AA0247
codeunit 5220 "Create Sustain. No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(JournalNoSeries(), SustainabilityJournalNoSeriesDescriptionTok, JournalStartingNoLbl, JournalEndingNoLbl, '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(RecurringJournalNoSeries(), RecurringJournalNoSeriesDescriptionTok, RecurringJournalStartingNoLbl, RecurringJournalEndingNoLbl, '', '', 1, Enum::"No. Series Implementation"::Normal, true);
    end;

    procedure JournalNoSeries(): Code[20]
    begin
        exit(SustainabilityJournalNoSeriesTok);
    end;

    procedure RecurringJournalNoSeries(): Code[20]
    begin
        exit(RecurringJournalNoSeriesTok);
    end;

    var
        SustainabilityJournalNoSeriesTok: Label 'SUSTAIN-JNL', MaxLength = 20;
        SustainabilityJournalNoSeriesDescriptionTok: Label 'Sustainability Journals', MaxLength = 100;
        JournalStartingNoLbl: Label 'SJ00001', MaxLength = 20;
        JournalEndingNoLbl: Label 'SJ99999', MaxLength = 20;
        RecurringJournalNoSeriesTok: Label 'SUSTAIN-RCJNL', MaxLength = 20;
        RecurringJournalNoSeriesDescriptionTok: Label 'Recurring Sustainability Journals', MaxLength = 100;
        RecurringJournalStartingNoLbl: Label 'SRJ00001', MaxLength = 20;
        RecurringJournalEndingNoLbl: Label 'SRJ99999', MaxLength = 20;
}
