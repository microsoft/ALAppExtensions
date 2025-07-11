namespace Microsoft.Sustainability.Journal;

page 6215 "Recurring Sustainability Jnl."
{
    ApplicationArea = Basic, Suite;
    Caption = 'Recurring Sustainability Journal';
    UsageCategory = Tasks;
    Description = 'Redirect to the Sustainability Journal page with the Recurring View.';

    trigger OnOpenPage()
    var
        SustainabilityJournal: Page "Sustainability Journal";
    begin
        SustainabilityJournal.SetRecurringView();
        SustainabilityJournal.Run();

        Error('');
    end;
}