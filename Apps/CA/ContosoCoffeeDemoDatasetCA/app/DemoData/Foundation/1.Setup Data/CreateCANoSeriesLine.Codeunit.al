codeunit 27055 "Create CA No. Series Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"No. Series Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "No. Series Line")
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        case Rec."Series Code" of
            CreateNoSeries.SalesCreditMemo():
                ValidateRecordFields(Rec, 'S-CR1001', 'S-CR2999', 'S-CR2995', '');
            CreateNoSeries.PostedSalesCreditMemo():
                ValidateRecordFields(Rec, 'PS-CR104001', 'PS-CR105999', 'PS-CR105995', '');
            CreateNoSeries.FinanceChargeMemo():
                ValidateRecordFields(Rec, 'S-FIN1001', 'S-FIN2999', 'S-FIN2995', '');
            CreateNoSeries.IssuedFinanceChargeMemo():
                ValidateRecordFields(Rec, 'S-FIN106001', 'S-FIN107999', 'S-FIN107995', '');
            CreateNoSeries.SalesInvoice():
                ValidateRecordFields(Rec, 'S-INV102001', 'S-INV103999', 'S-INV103995', '');
            CreateNoSeries.PostedSalesInvoice():
                ValidateRecordFields(Rec, 'PS-INV103001', 'PS-INV104999', 'PS-INV104995', '');
            CreateNoSeries.SalesOrder():
                ValidateRecordFields(Rec, 'S-ORD101001', 'S-ORD102999', 'S-ORD102995', '');
            CreateNoSeries.SalesPriceList():
                ValidateRecordFields(Rec, 'S-PLS00001', 'S-PLS99999', '', '');
            CreateNoSeries.SalesQuote():
                ValidateRecordFields(Rec, 'S-QUO1001', 'S-QUO2999', 'S-QUO2995', '');
            CreateNoSeries.PostedSalesReceipt():
                ValidateRecordFields(Rec, 'S-RCPT107001', 'S-RCPT108999', 'S-RCPT108995', '');
            CreateNoSeries.Reminder():
                ValidateRecordFields(Rec, 'S-REM1001', 'S-REM2999', 'S-REM2995', '');
            CreateNoSeries.IssuedReminder():
                ValidateRecordFields(Rec, 'S-REM105001', 'S-REM106999', 'S-REM106995', '');
            CreateNoSeries.SalesReturnOrder():
                ValidateRecordFields(Rec, 'S-RETORD1001', 'S-RETORD2999', 'S-RETORD2995', '');
            CreateNoSeries.SalesShipment():
                ValidateRecordFields(Rec, 'S-SHPT102001', 'S-SHPT103999', 'S-SHPT103995', '');
        end;
    end;

    procedure ValidateRecordFields(var NoSeriesLine: Record "No. Series Line"; StartingNo: Code[20]; EndingNo: Code[20]; WarningNo: Code[20]; LastNoUsed: Code[20])
    begin
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Warning No.", WarningNo);
        NoSeriesLine.Validate("Last No. Used", LastNoUsed);
    end;
}