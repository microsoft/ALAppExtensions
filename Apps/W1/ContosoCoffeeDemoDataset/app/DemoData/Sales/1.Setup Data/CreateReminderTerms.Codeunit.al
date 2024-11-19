codeunit 5303 "Create Reminder Terms"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoReminder: Codeunit "Contoso Reminder";
    begin
        ContosoReminder.InsertReminderTerms(Domestic(), DomesticCustomersLbl);
        ContosoReminder.InsertReminderTerms(Foreign(), ForeignCustomersLbl);
    end;

    procedure Domestic(): Code[10]
    begin
        exit(DomesticTok);
    end;

    procedure Foreign(): Code[10]
    begin
        exit(ForeignTok);
    end;

    var
        DomesticTok: Label 'DOMESTIC', MaxLength = 10;
        ForeignTok: Label 'FOREIGN', MaxLength = 10;
        DomesticCustomersLbl: Label 'Domestic Customers', MaxLength = 100;
        ForeignCustomersLbl: Label 'Foreign Customers', MaxLength = 100;
}