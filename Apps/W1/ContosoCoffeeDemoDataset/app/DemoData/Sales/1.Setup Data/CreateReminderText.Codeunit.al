codeunit 5268 "Create Reminder Text"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateReminderTerms: Codeunit "Create Reminder Terms";
        CreateReminderLevel: Codeunit "Create Reminder Level";
        ContosoReminder: Codeunit "Contoso Reminder";
    begin
        ContosoReminder.InsertReminderText(CreateReminderTerms.Domestic(), CreateReminderLevel.DomesticLevel1(), Enum::"Reminder Text Position"::Ending, 10000, DomesticPmtReminderLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Domestic(), CreateReminderLevel.DomesticLevel2(), Enum::"Reminder Text Position"::Ending, 10000, BalanceLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Domestic(), CreateReminderLevel.DomesticLevel2(), Enum::"Reminder Text Position"::Ending, 20000, AccountAgencyLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Domestic(), CreateReminderLevel.DomesticLevel3(), Enum::"Reminder Text Position"::Ending, 20000, ReminderLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Domestic(), CreateReminderLevel.DomesticLevel3(), Enum::"Reminder Text Position"::Ending, 30000, AccountAttorneyLbl);

        ContosoReminder.InsertReminderText(CreateReminderTerms.Foreign(), CreateReminderLevel.DomesticLevel1(), Enum::"Reminder Text Position"::Ending, 30000, DomesticPmtReminderLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Foreign(), CreateReminderLevel.DomesticLevel2(), Enum::"Reminder Text Position"::Ending, 30000, BalanceLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Foreign(), CreateReminderLevel.DomesticLevel2(), Enum::"Reminder Text Position"::Ending, 40000, AccountAgencyLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Foreign(), CreateReminderLevel.DomesticLevel3(), Enum::"Reminder Text Position"::Ending, 40000, ReminderLbl);
        ContosoReminder.InsertReminderText(CreateReminderTerms.Foreign(), CreateReminderLevel.DomesticLevel3(), Enum::"Reminder Text Position"::Ending, 50000, AccountAttorneyLbl);
    end;

    var
        DomesticPmtReminderLbl: Label 'Please remit your payment of %7 as soon as possible.', MaxLength = 100, Comment = '%7 Document Type';
        BalanceLbl: Label 'If the balance is not received within 10 days,', MaxLength = 100;
        AccountAgencyLbl: Label 'your account will be sent to a collection agency.', MaxLength = 100;
        ReminderLbl: Label 'This is reminder number %8.', MaxLength = 100, Comment = '%8 No. of Reminders';
        AccountAttorneyLbl: Label 'Your account has now been sent to our attorney.', MaxLength = 100;
}