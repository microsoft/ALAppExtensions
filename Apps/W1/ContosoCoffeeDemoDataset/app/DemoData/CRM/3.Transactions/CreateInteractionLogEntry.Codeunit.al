codeunit 5679 "Create Interaction Log Entry"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateInteractionLogEntryForCustomer();
        CreateInteractionLogEntryForContact();
        CreateInteractionLogEntryForPurchaseHeader();
        CreateInteractionLogEntryForSalesHeader();
    end;


    procedure CreateInteractionLogEntryForSalesHeader()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", "Sales Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                SegManagement.LogDocument(
                    3, SalesHeader."No.", 0, 0, Database::Customer, SalesHeader."Bill-to Customer No.", SalesHeader."Salesperson Code",
                    SalesHeader."Campaign No.", SalesHeader."Posting Description", '');
                InteractionLogEntry.FindLast();
                InteractionLogEntry.Date := SalesHeader."Posting Date";
                InteractionLogEntry.Modify();
            until SalesHeader.Next() = 0;

        SalesHeader.SetRange("Document Type", "Sales Document Type"::Quote);
        if SalesHeader.FindSet() then
            repeat
                SegManagement.LogDocument(
                    1, SalesHeader."No.", SalesHeader."Doc. No. Occurrence", SalesHeader."No. of Archived Versions", Database::Contact, SalesHeader."Bill-to Contact No.",
                    SalesHeader."Salesperson Code", SalesHeader."Campaign No.", SalesHeader."Posting Description", SalesHeader."Opportunity No.");
                InteractionLogEntry.FindLast();
                InteractionLogEntry.Date := SalesHeader."Posting Date";
                InteractionLogEntry.Modify();
            until SalesHeader.Next() = 0;
    end;

    procedure CreateInteractionLogEntryForPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("Document Type", "Purchase Document Type"::Order);
        if PurchaseHeader.FindSet() then
            repeat
                SegManagement.LogDocument(
                    13, PurchaseHeader."No.", 0, 0, Database::Vendor, PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Purchaser Code",
                    PurchaseHeader."Campaign No.", PurchaseHeader."Posting Description", '');
                InteractionLogEntry.FindLast();
                InteractionLogEntry.Date := PurchaseHeader."Posting Date";
                InteractionLogEntry.Modify();
            until PurchaseHeader.Next() = 0;
    end;

    local procedure CreateInteractionLogEntryForContact()
    var
        Contact: Record Contact;
    begin
        if Contact.FindSet() then
            repeat
                SegManagement.LogDocument(17, '', 0, 0, Database::Contact, Contact."No.", '', '', '', '');
                InteractionLogEntry.FindLast();
                InteractionLogEntry.Date := WorkDate();
                InteractionLogEntry.Modify();
            until Contact.Next() = 0;
    end;

    local procedure CreateInteractionLogEntryForCustomer()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                SegManagement.LogDocument(
                      7, Format(Customer."Last Statement No."), 0, 0, Database::Customer, Customer."No.",
                      Customer."Salesperson Code", '', StatementLbl, '');
                InteractionLogEntry.FindLast();
                InteractionLogEntry.Date := WorkDate();
                InteractionLogEntry.Modify();
            until Customer.Next() = 0;
    end;

    var
        InteractionLogEntry: Record "Interaction Log Entry";
        SegManagement: Codeunit SegManagement;
        StatementLbl: Label 'Statement ';
}

