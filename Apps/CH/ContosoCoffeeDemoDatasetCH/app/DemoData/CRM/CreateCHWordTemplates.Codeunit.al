codeunit 11634 "Create CH Word Templates"
{
    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
        FolderNameLbl: Label 'WordTemplates', Locked = true;
    begin
        ContosoCRM.InsertWordTemplate(EventDEWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_DES.docx', CreateLanguage.DES());
        ContosoCRM.InsertWordTemplate(EventFRWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_FRS.docx', CreateLanguage.FRS());
        ContosoCRM.InsertWordTemplate(EventITWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_ITS.docx', CreateLanguage.ITS());

        ContosoCRM.InsertWordTemplate(MemoDEWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_DES.docx', CreateLanguage.DES());
        ContosoCRM.InsertWordTemplate(MemoFRWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_FRS.docx', CreateLanguage.FRS());
        ContosoCRM.InsertWordTemplate(MemoITWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_ITS.docx', CreateLanguage.ITS());

        ContosoCRM.InsertWordTemplate(ThanksNoteDEWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_DES.docx', CreateLanguage.DES());
        ContosoCRM.InsertWordTemplate(ThanksNoteFRWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_FRS.docx', CreateLanguage.FRS());
        ContosoCRM.InsertWordTemplate(ThanksNoteITWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_ITS.docx', CreateLanguage.ITS());
    end;

    procedure EventDEWordTemplate(): Code[30]
    begin
        exit(EventDETok);
    end;

    procedure EventFRWordTemplate(): Code[30]
    begin
        exit(EventFRTok);
    end;

    procedure EventITWordTemplate(): Code[30]
    begin
        exit(EventITTok);
    end;

    procedure ThanksNoteDEWordTemplate(): Code[30]
    begin
        exit(ThanksNoteDETok);
    end;

    procedure ThanksNoteFRWordTemplate(): Code[30]
    begin
        exit(ThanksNoteFRTok);
    end;

    procedure ThanksNoteITWordTemplate(): Code[30]
    begin
        exit(ThanksNoteITTok);
    end;

    procedure MemoDEWordTemplate(): Code[30]
    begin
        exit(MemoDETok);
    end;

    procedure MemoFRWordTemplate(): Code[30]
    begin
        exit(MemoFRTok);
    end;

    procedure MemoITWordTemplate(): Code[30]
    begin
        exit(MemoITTok);
    end;

    var
        EventDETok: Label 'Event-DE', MaxLength = 30;
        EventFRTok: Label 'Event-FR', MaxLength = 30;
        EventITTok: Label 'Event-IT', MaxLength = 30;
        ThanksNoteDETok: Label 'THANKSNOTE-DE', MaxLength = 30;
        ThanksNoteFRTok: Label 'THANKSNOTE-FR', MaxLength = 30;
        ThanksNoteITTok: Label 'THANKSNOTE-IT', MaxLength = 30;
        MemoDETok: Label 'MEMO-DE', MaxLength = 30;
        MemoFRTok: Label 'MEMO-FR', MaxLength = 30;
        MemoITTok: Label 'MEMO-IT', MaxLength = 30;
        CustomerEventLbl: Label 'Customer Event';
        ContactThanksNoteLbl: Label 'Contact Thanks Note';
        VendorMemoLbl: Label 'Vendor Memo';

}