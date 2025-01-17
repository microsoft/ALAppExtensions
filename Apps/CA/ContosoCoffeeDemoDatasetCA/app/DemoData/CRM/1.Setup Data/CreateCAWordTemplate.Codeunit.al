codeunit 27068 "Create CA Word Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
        FolderNameLbl: Label 'WordTemplates', Locked = true;
    begin
        ContosoCRM.InsertWordTemplate(EventWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_ENC.docx', CreateLanguage.ENC());
        ContosoCRM.InsertWordTemplate(MemoWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_ENC.docx', CreateLanguage.ENC());
        ContosoCRM.InsertWordTemplate(ThanksNoteWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_ENC.docx', CreateLanguage.ENC());

        ContosoCRM.InsertWordTemplate(EventFRWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_FRC.docx', CreateLanguage.FRC());
        ContosoCRM.InsertWordTemplate(MemoFRWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_FRC.docx', CreateLanguage.FRC());
        ContosoCRM.InsertWordTemplate(ThanksNoteFRWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_FRC.docx', CreateLanguage.FRC());
    end;

    procedure EventWordTemplate(): Code[30]
    begin
        exit(EventTok)
    end;

    procedure MemoWordTemplate(): Code[30]
    begin
        exit(MemoTok)
    end;

    procedure ThanksNoteWordTemplate(): Code[30]
    begin
        exit(ThanksNoteTok)
    end;

    procedure EventFRWordTemplate(): Code[30]
    begin
        exit(EventFRTok)
    end;

    procedure MemoFRWordTemplate(): Code[30]
    begin
        exit(MemoFRTok)
    end;

    procedure ThanksNoteFRWordTemplate(): Code[30]
    begin
        exit(ThanksNoteFRTok)
    end;

    var
        EventTok: Label 'EVENT-EN', MaxLength = 30;
        MemoTok: Label 'MEMO-EN', MaxLength = 30;
        ThanksNoteTok: Label 'THANKSNOTE-EN', MaxLength = 30;
        EventFRTok: Label 'EVENT-FR', MaxLength = 30;
        MemoFRTok: Label 'MEMO-FR', MaxLength = 30;
        ThanksNoteFRTok: Label 'THANKSNOTE-FR', MaxLength = 30;
        CustomerEventLbl: Label 'Customer Event', MaxLength = 250;
        VendorMemoLbl: Label 'Vendor Memo', MaxLength = 250;
        ContactThanksNoteLbl: Label 'Contact Thanks Note', MaxLength = 250;
}