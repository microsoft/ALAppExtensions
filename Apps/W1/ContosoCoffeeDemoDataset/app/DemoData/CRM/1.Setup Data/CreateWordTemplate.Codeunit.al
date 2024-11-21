codeunit 5410 "Create Word Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
        FolderNameLbl: Label 'WordTemplates', Locked = true;
    begin
        ContosoCRM.InsertWordTemplate(EventWordTemplate(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event.docx', CreateLanguage.ENU());
        ContosoCRM.InsertWordTemplate(MemoWordTemplate(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo.docx', CreateLanguage.ENU());
        ContosoCRM.InsertWordTemplate(ThanksNoteWordTemplate(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote.docx', CreateLanguage.ENU());
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

    var
        EventTok: Label 'EVENT', MaxLength = 30;
        MemoTok: Label 'MEMO', MaxLength = 30;
        ThanksNoteTok: Label 'THANKSNOTE', MaxLength = 30;
        CustomerEventLbl: Label 'Customer Event', MaxLength = 250;
        VendorMemoLbl: Label 'Vendor Memo', MaxLength = 250;
        ContactThanksNoteLbl: Label 'Contact Thanks Note', MaxLength = 250;
}