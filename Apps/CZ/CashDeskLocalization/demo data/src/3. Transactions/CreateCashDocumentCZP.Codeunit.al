#pragma warning disable AA0247
codeunit 31469 "Create Cash Document CZP"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        ContosoCashDeskCZP: Codeunit "Contoso Cash Desk CZP";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateCashDeskCZP: Codeunit "Create Cash Desk CZP";
        CreateCashDeskEventCZP: Codeunit "Create Cash Desk Event CZP";
    begin
        CashDocumentHeaderCZP := ContosoCashDeskCZP.InsertCashDocumentHeader(CreateCashDeskCZP.CashDeskOne(), Enum::"Cash Document Type CZP"::Receipt, ContosoUtilities.AdjustDate(19030129D), CashdeposittothecashdeskLbl);
        ContosoCashDeskCZP.InsertCashDocumentLine(CashDocumentHeaderCZP, CreateCashDeskEventCZP.Subsidy(), 10000.00, CashdeposittothecashdeskLbl);
        CashDocumentHeaderCZP := ContosoCashDeskCZP.InsertCashDocumentHeader(CreateCashDeskCZP.CashDeskOne(), Enum::"Cash Document Type CZP"::Receipt, ContosoUtilities.AdjustDate(19030131D), CashdepositfromtheaccountLbl);
        ContosoCashDeskCZP.InsertCashDocumentLine(CashDocumentHeaderCZP, CreateCashDeskEventCZP.Subsidy(), 15000.00, CashtranferLbl);
        CashDocumentHeaderCZP := ContosoCashDeskCZP.InsertCashDocumentHeader(CreateCashDeskCZP.CashDeskOne(), Enum::"Cash Document Type CZP"::Withdrawal, ContosoUtilities.AdjustDate(19030129D), FuelpurchaseLbl);
        ContosoCashDeskCZP.InsertCashDocumentLine(CashDocumentHeaderCZP, CreateCashDeskEventCZP.Fuel(), 2000.00, FuelLbl);
        CashDocumentHeaderCZP := ContosoCashDeskCZP.InsertCashDocumentHeader(CreateCashDeskCZP.CashDeskOne(), Enum::"Cash Document Type CZP"::Withdrawal, ContosoUtilities.AdjustDate(19030129D), CashdeposittothebankLbl);
        ContosoCashDeskCZP.InsertCashDocumentLine(CashDocumentHeaderCZP, CreateCashDeskEventCZP.Transfer(), 5000.00, CashtranferLbl);
        CashDocumentHeaderCZP := ContosoCashDeskCZP.InsertCashDocumentHeader(CreateCashDeskCZP.CashDeskOne(), Enum::"Cash Document Type CZP"::Withdrawal, ContosoUtilities.AdjustDate(19030131D), PurchaseofofficesuppliesLbl);
        ContosoCashDeskCZP.InsertCashDocumentLine(CashDocumentHeaderCZP, CreateCashDeskEventCZP.OfficeSupplies(), 350.00, OfficesuppliesLbl);
    end;

    procedure ReleaseCashDocuments()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        CashDocumentHeaderCZP.SetRange("Posting Date", ContosoUtilities.AdjustDate(19030129D));
        if CashDocumentHeaderCZP.FindSet() then
            repeat
                CashDocumentReleaseCZP.Run(CashDocumentHeaderCZP);
            until CashDocumentHeaderCZP.Next() = 0;
    end;

    procedure PostCashDocuments()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        CashDocumentHeaderCZP.SetRange("Posting Date", ContosoUtilities.AdjustDate(19030131D));
        if CashDocumentHeaderCZP.FindSet() then
            repeat
                CashDocumentPostCZP.Run(CashDocumentHeaderCZP);
            until CashDocumentHeaderCZP.Next() = 0;
    end;

    var
        CashdeposittothecashdeskLbl: Label 'Cash deposit to the cash desk', MaxLength = 100;
        CashdepositfromtheaccountLbl: Label 'Cash deposit from the account', MaxLength = 100;
        CashdeposittothebankLbl: Label 'Cash deposit to the bank', MaxLength = 100;
        FuelpurchaseLbl: Label 'Fuel purchase', MaxLength = 100;
        PurchaseofofficesuppliesLbl: Label 'Purchase of office supplies', MaxLength = 100;
        CashtranferLbl: Label 'Cash tranfer', MaxLength = 100;
        FuelLbl: Label 'Fuel', MaxLength = 100;
        OfficesuppliesLbl: Label 'Office supplies', MaxLength = 100;
}