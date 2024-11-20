codeunit 5534 "Create Interaction Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertInteractionGroup(Letter(), LettersLbl);
        ContosoCRM.InsertInteractionGroup(Meeting(), MeetingsLbl);
        ContosoCRM.InsertInteractionGroup(Phone(), TelephoneConversationsLbl);
        ContosoCRM.InsertInteractionGroup(Purchase(), PurchaseDocumentsLbl);
        ContosoCRM.InsertInteractionGroup(Sales(), SalesDocumentsLbl);
        ContosoCRM.InsertInteractionGroup(System(), SystemGeneratedEntriesLbl);
    end;

    procedure Letter(): Code[10]
    begin
        exit(LetterTok);
    end;

    procedure Meeting(): Code[10]
    begin
        exit(MeetingTok);
    end;

    procedure Phone(): Code[10]
    begin
        exit(PhoneTok);
    end;

    procedure System(): Code[10]
    begin
        exit(SystemTok);
    end;

    procedure Sales(): Code[10]
    begin
        exit(SalesTok);
    end;

    procedure Purchase(): Code[10]
    begin
        exit(PurchasesTok);
    end;

    var
        LetterTok: Label 'LETTER', MaxLength = 10;
        MeetingTok: Label 'MEETING', MaxLength = 10;
        PhoneTok: Label 'PHONE', MaxLength = 10;
        SalesTok: Label 'SALES', MaxLength = 10;
        PurchasesTok: Label 'PURCHASES', MaxLength = 10;
        SystemTok: Label 'SYSTEM', MaxLength = 10;
        LettersLbl: Label 'Letters', MaxLength = 100;
        MeetingsLbl: Label 'Meetings', MaxLength = 100;
        TelephoneConversationsLbl: Label 'Telephone conversations', MaxLength = 100;
        PurchaseDocumentsLbl: Label 'Purchase Documents', MaxLength = 100;
        SalesDocumentsLbl: Label 'Sales Documents', MaxLength = 100;
        SystemGeneratedEntriesLbl: Label 'System Generated Entries', MaxLength = 100;
}