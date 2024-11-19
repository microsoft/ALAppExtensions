codeunit 11144 "Create No. Series AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(PurchaseDeliveryReminder(), DeliveryReminderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseIssueDeliveryReminder(), IssueDeliveryReminderLbl, '104001', '105999', '105995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(Job(), JobLbl, 'J00010', 'J99990', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecordNoSeries(var Rec: Record "No. Series")
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        case Rec.Code of
            CreateNoSeries.Contact():
                ValidateRecordFieldsNoSeries(Rec, true);
            CreateNoSeries.CashFlow():
                ValidateRecordFieldsNoSeries(Rec, true);
            CreateNoSeries.BlanketPurchaseOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseCreditMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedPurchaseCreditMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseInvoice():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedPurchaseInvoice():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseQuote():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseReceipt():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PurchaseReturnOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedPurchaseShipment():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.BlanketSalesOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesCreditMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedSalesCreditMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.FinanceChargeMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.IssuedFinanceChargeMemo():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesInvoice():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedSalesInvoice():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesQuote():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.PostedSalesReceipt():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.Reminder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.IssuedReminder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesReturnOrder():
                ValidateRecordFieldsNoSeries(Rec, false);
            CreateNoSeries.SalesShipment():
                ValidateRecordFieldsNoSeries(Rec, false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"No. Series Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "No. Series Line")
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        case Rec."Series Code" of
            CreateNoSeries.CashFlow():
                ValidateRecordFieldsWithStartingNo(Rec, 'CF100001', 'CF200000');
            CreateNoSeries.PurchasePriceList():
                ValidateRecordFieldsWithStartingNo(Rec, 'P00001', 'P99999');
            CreateNoSeries.PaymentReconciliationJournals():
                ValidateRecordFieldsWithStartingNo(Rec, 'PREC000', 'PREC999');
            CreateNoSeries.TransferReceipt():
                ValidateRecordFieldsWithStartingNo(Rec, '109001', '1010999');
            CreateNoSeries.VATReturnPeriods():
                ValidateRecordFieldsWithStartingNo(Rec, 'VATPER-0001', 'VATPER-9999');
            CreateNoSeries.VATReturnsReports():
                ValidateRecordFieldsWithStartingNo(Rec, 'VATRET-0001', 'VATRET-9999');
        end;
    end;

    procedure ValidateRecordFieldsNoSeries(var NoSeries: Record "No. Series"; ManualNos: Boolean)
    begin
        NoSeries.Validate("Manual Nos.", ManualNos);
    end;

    procedure ValidateRecordFieldsWithStartingNo(var NoSeriesLine: Record "No. Series Line"; StartingNo: Code[20]; EndingNo: Code[20])
    begin
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
    end;

    procedure PurchaseDeliveryReminder(): Code[20]
    begin
        exit('P-DELREM');
    end;

    procedure PurchaseIssueDeliveryReminder(): Code[20]
    begin
        exit('P-DELREM+');
    end;

    procedure Job(): Code[20]
    begin
        exit(JobTok);
    end;

    var
        JobTok: Label 'JOB', MaxLength = 20;
        JobLbl: Label 'JOB', MaxLength = 100;
        DeliveryReminderLbl: Label 'Purchase Delivery Reminder', MaxLength = 100;
        IssueDeliveryReminderLbl: Label 'Issued Purch. Deliv. Reminder', MaxLength = 100;
}