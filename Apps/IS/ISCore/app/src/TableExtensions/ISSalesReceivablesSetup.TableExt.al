tableextension 14603 "IS Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(14601; "Electronic Invoicing Reminder"; Boolean)
        {
            Caption = 'Electronic Invoicing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Electronic Invoicing Reminder" then
                    Message(ReminderMsg);
            end;
        }
    }

    procedure GetLegalStatementLabel(): Text
    begin
#if not CLEAN24
        if not ISCoreAppSetup.IsEnabled() then
#endif
            if "Electronic Invoicing Reminder" then
                exit(LocalLegalStatementCaptionLbl);
    end;

    var
        ReminderMsg: Label 'Reminder to read legal restrictions on form and print/send statement';
        LocalLegalStatementCaptionLbl: Label 'This invoice originates in a ERP system that conforms with regulation no. 505/2013';
}
