codeunit 5486 "Create Job Responsibility"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertJobResponsibility(AccPayable(), AccountsPayableResponsibleLbl);
        ContosoCRM.InsertJobResponsibility(AccReceivable(), AccsReceivableResponsibleLbl);
        ContosoCRM.InsertJobResponsibility(Marketing(), MarketingResponsibleLbl);
        ContosoCRM.InsertJobResponsibility(Purchase(), PurchaseResponsibleLbl);
        ContosoCRM.InsertJobResponsibility(Sale(), SalesResponsibleLbl);
    end;

    procedure AccPayable(): Code[10]
    begin
        exit(AccPayableTok);
    end;

    procedure AccReceivable(): Code[10]
    begin
        exit(AccReceivableTok);
    end;

    procedure Marketing(): Code[10]
    begin
        exit(MarketingTok);
    end;

    procedure Purchase(): Code[10]
    begin
        exit(PurchaseTok);
    end;

    procedure Sale(): Code[10]
    begin
        exit(SaleTok);
    end;

    var
        AccPayableTok: Label 'APR', MaxLength = 10;
        AccReceivableTok: Label 'ARR', MaxLength = 10;
        MarketingTok: Label 'MARKETING', MaxLength = 10;
        PurchaseTok: Label 'PURCHASE', MaxLength = 10;
        SaleTok: Label 'SALE', MaxLength = 10;
        AccountsPayableResponsibleLbl: Label 'Accounts Payable Responsible', MaxLength = 100;
        AccsReceivableResponsibleLbl: Label 'Accs. Receivable Responsible', MaxLength = 100;
        MarketingResponsibleLbl: Label 'Marketing Responsible', MaxLength = 100;
        PurchaseResponsibleLbl: Label 'Purchase Responsible', MaxLength = 100;
        SalesResponsibleLbl: Label 'Sales Responsible', MaxLength = 100;
}