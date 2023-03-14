tableextension 31049 "Incoming Document CZZ" extends "Incoming Document"
{
    #region purchase
    procedure SetPurchaseAdvanceCZZ(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        if PurchAdvLetterHeaderCZZ."Incoming Document Entry No." = 0 then
            exit;

        Get(PurchAdvLetterHeaderCZZ."Incoming Document Entry No.");
        TestReadyForProcessing();
        TestIfAlreadyExists();
        "Document Type" := "Document Type"::"Purchase Advance CZZ";
        Modify();
        if not DocLinkExists(PurchAdvLetterHeaderCZZ) then
            PurchAdvLetterHeaderCZZ.AddLink(GetURL(), Description);
    end;

    procedure CreatePurchAdvLetterCZZ()
    var
        AdvanceLetterTemplate: Record "Advance Letter Template CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if "Document Type" <> "Document Type"::"Purchase Advance CZZ" then
            TestIfAlreadyExists();

        "Document Type" := "Document Type"::"Purchase Advance CZZ";
        TestReadyForProcessing();
        PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", "Entry No.");
        if not PurchAdvLetterHeaderCZZ.IsEmpty() then begin
            ShowRecord();
            exit;
        end;

        AdvanceLetterTemplate.SetRange("Sales/Purchase", AdvanceLetterTemplate."Sales/Purchase"::Purchase);
        if Page.RunModal(0, AdvanceLetterTemplate) <> Action::LookupOK then
            Error('');

        PurchAdvLetterHeaderCZZ.Reset();
        PurchAdvLetterHeaderCZZ.Init();
        PurchAdvLetterHeaderCZZ."Advance Letter Code" := AdvanceLetterTemplate.Code;
        PurchAdvLetterHeaderCZZ.Insert(true);
        if GetURL() <> '' then
            PurchAdvLetterHeaderCZZ.AddLink(GetURL(), Description);
        PurchAdvLetterHeaderCZZ."Incoming Document Entry No." := "Entry No.";
        PurchAdvLetterHeaderCZZ.Modify();
        "Document No." := PurchAdvLetterHeaderCZZ."No.";
        Modify(true);
        Commit();
        ShowRecord();
    end;
    #endregion purchase

    #region sales
    procedure SetSalesAdvanceCZZ(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        if SalesAdvLetterHeaderCZZ."Incoming Document Entry No." = 0 then
            exit;

        Get(SalesAdvLetterHeaderCZZ."Incoming Document Entry No.");
        TestReadyForProcessing();
        TestIfAlreadyExists();
        "Document Type" := "Document Type"::"Purchase Advance CZZ";
        Modify();
        if not DocLinkExists(SalesAdvLetterHeaderCZZ) then
            SalesAdvLetterHeaderCZZ.AddLink(GetURL(), Description);
    end;

    procedure CreateSalesAdvLetterCZZ()
    var
        AdvanceLetterTemplate: Record "Advance Letter Template CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if "Document Type" <> "Document Type"::"Sales Advance CZZ" then
            TestIfAlreadyExists();

        "Document Type" := "Document Type"::"Sales Advance CZZ";
        TestReadyForProcessing();
        SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", "Entry No.");
        if not SalesAdvLetterHeaderCZZ.IsEmpty() then begin
            ShowRecord();
            exit;
        end;

        AdvanceLetterTemplate.SetRange("Sales/Purchase", AdvanceLetterTemplate."Sales/Purchase"::Sales);
        if Page.RunModal(0, AdvanceLetterTemplate) <> Action::LookupOK then
            Error('');

        SalesAdvLetterHeaderCZZ.Reset();
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ."Advance Letter Code" := AdvanceLetterTemplate.Code;
        SalesAdvLetterHeaderCZZ.Insert(true);
        if GetURL() <> '' then
            SalesAdvLetterHeaderCZZ.AddLink(GetURL(), Description);
        SalesAdvLetterHeaderCZZ."Incoming Document Entry No." := "Entry No.";
        SalesAdvLetterHeaderCZZ.Modify();
        "Document No." := SalesAdvLetterHeaderCZZ."No.";
        Modify(true);
        Commit();
        ShowRecord();
    end;
    #endregion sales
}
