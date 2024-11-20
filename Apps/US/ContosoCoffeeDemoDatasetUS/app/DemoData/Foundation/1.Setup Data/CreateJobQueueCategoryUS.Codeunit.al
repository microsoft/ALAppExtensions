codeunit 10534 "Create Job Queue Category US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoJobQueue: Codeunit "Contoso Job Queue";
    begin
        ContosoJobQueue.InsertJobQueueCategory(PurchPost(), PurchasePostCategoryLbl);
        ContosoJobQueue.InsertJobQueueCategory(SalesPost(), SalesPostCategoryLbl);
    end;

    procedure PurchPost(): Code[10]
    begin
        exit(PurchPostTok);
    end;

    procedure SalesPost(): Code[10]
    begin
        exit(SalesPostTok);
    end;

    var
        PurchPostTok: Label 'PURCHPOST', MaxLength = 10;
        SalesPostTok: Label 'SALESPOST', MaxLength = 10;
        PurchasePostCategoryLbl: Label 'Purchase Posting', MaxLength = 30;
        SalesPostCategoryLbl: Label 'Sales Posting', MaxLength = 30;
}