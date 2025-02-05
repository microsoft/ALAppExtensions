codeunit 5304 "Create Reminder Level"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoReminder: Codeunit "Contoso Reminder";
        CreateReminderTerms: Codeunit "Create Reminder Terms";
    begin
        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Domestic(), DomesticLevel1(), '<2D>', 5, '<7D>');
        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Domestic(), DomesticLevel2(), '<2D>', 10, '<7D>');
        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Domestic(), DomesticLevel3(), '<2D>', 15, '<7D>');

        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Foreign(), ForeignLevel1(), '<3D>', 0, '<7D>');
        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Foreign(), ForeignLevel2(), '<3D>', 0, '<7D>');
        ContosoReminder.InsertReminderLevel(CreateReminderTerms.Foreign(), ForeignLevel3(), '<3D>', 0, '<7D>');
    end;

    procedure DomesticLevel1(): Integer
    begin
        exit(1);
    end;

    procedure DomesticLevel2(): Integer
    begin
        exit(2);
    end;

    procedure DomesticLevel3(): Integer
    begin
        exit(3);
    end;

    procedure ForeignLevel1(): Integer
    begin
        exit(1);
    end;

    procedure ForeignLevel2(): Integer
    begin
        exit(2);
    end;

    procedure ForeignLevel3(): Integer
    begin
        exit(3);
    end;
}