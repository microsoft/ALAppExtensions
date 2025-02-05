codeunit 5693 "Create Posted Sales Data"
{
    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        CreateSalesDocument: Codeunit "Create Sales Document";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetFilter("Your Reference", '<>%1', CreateSalesDocument.OpenYourReference());
        if SalesHeader.Findset() then
            repeat
                SalesHeader.Validate(Invoice, true);
                SalesHeader.Validate(Ship, true);
                CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
            until SalesHeader.Next() = 0;
    end;
}