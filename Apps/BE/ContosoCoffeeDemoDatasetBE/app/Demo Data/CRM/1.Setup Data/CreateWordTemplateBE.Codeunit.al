codeunit 11410 "Create Word Template BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateLanguage: Codeunit "Create Language";
        FolderNameLbl: Label 'WordTemplates', Locked = true;
    begin
        ContosoCRM.InsertWordTemplate(EventWordTemplateFR(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_FRB.docx', CreateLanguage.FRB());
        ContosoCRM.InsertWordTemplate(MemoWordTemplateFR(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_FRB.docx', CreateLanguage.FRB());
        ContosoCRM.InsertWordTemplate(ThanksNoteWordTemplateFR(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_FRB.docx', CreateLanguage.FRB());

        ContosoCRM.InsertWordTemplate(EventWordTemplateNL(), CustomerEventLbl, Database::Customer, FolderNameLbl + '/WordTemplate_Customer_Event_NLB.docx', CreateLanguage.NLB());
        ContosoCRM.InsertWordTemplate(MemoWordTemplateNL(), VendorMemoLbl, Database::Vendor, FolderNameLbl + '/WordTemplate_Vendor_Memo_NLB.docx', CreateLanguage.NLB());
        ContosoCRM.InsertWordTemplate(ThanksNoteWordTemplateNL(), ContactThanksNoteLbl, Database::Contact, FolderNameLbl + '/WordTemplate_Contact_Thanksnote_NLB.docx', CreateLanguage.NLB());
    end;

    procedure EventWordTemplateFR(): Code[30]
    begin
        exit(EventFRTok)
    end;

    procedure EventWordTemplateNL(): Code[30]
    begin
        exit(EventNLTok)
    end;

    procedure MemoWordTemplateFR(): Code[30]
    begin
        exit(MemoFRTok)
    end;

    procedure MemoWordTemplateNL(): Code[30]
    begin
        exit(MemoNLTok)
    end;

    procedure ThanksNoteWordTemplateFR(): Code[30]
    begin
        exit(ThanksNoteFRTok)
    end;

    procedure ThanksNoteWordTemplateNL(): Code[30]
    begin
        exit(ThanksNoteNLTok)
    end;

    var
        EventFRTok: Label 'EVENT-FR', MaxLength = 30, Locked = true;
        EventNLTok: Label 'EVENT-NL', MaxLength = 30, Locked = true;
        MemoFRTok: Label 'MEMO-FR', MaxLength = 30, Locked = true;
        MemoNLTok: Label 'MEMO-NL', MaxLength = 30, Locked = true;
        ThanksNoteFRTok: Label 'THANKSNOTE-FR', MaxLength = 30, Locked = true;
        ThanksNoteNLTok: Label 'THANKSNOTE-NL', MaxLength = 30, Locked = true;
        CustomerEventLbl: Label 'Customer Event', MaxLength = 250;
        VendorMemoLbl: Label 'Vendor Memo', MaxLength = 250;
        ContactThanksNoteLbl: Label 'Contact Thanks Note', MaxLength = 250;
}