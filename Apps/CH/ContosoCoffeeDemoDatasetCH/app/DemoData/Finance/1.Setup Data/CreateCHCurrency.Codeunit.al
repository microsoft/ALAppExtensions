codeunit 11629 "Create CH Currency"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        case Rec.Code of
            CreateCurrency.AED(),
            CreateCurrency.AUD(),
            CreateCurrency.BGN(),
            CreateCurrency.BND(),
            CreateCurrency.BRL(),
            CreateCurrency.CAD(),
            CreateCurrency.CZK(),
            CreateCurrency.DKK(),
            CreateCurrency.DZD(),
            CreateCurrency.EUR(),
            CreateCurrency.FJD(),
            CreateCurrency.HKD(),
            CreateCurrency.HRK(),
            CreateCurrency.HUF(),
            CreateCurrency.IDR(),
            CreateCurrency.INR(),
            CreateCurrency.ISK(),
            CreateCurrency.JPY(),
            CreateCurrency.KES(),
            CreateCurrency.MAD(),
            CreateCurrency.MXN(),
            CreateCurrency.MYR(),
            CreateCurrency.MZN(),
            CreateCurrency.NGN(),
            CreateCurrency.NOK(),
            CreateCurrency.NZD(),
            CreateCurrency.PHP(),
            CreateCurrency.PLN(),
            CreateCurrency.RON(),
            CreateCurrency.RSD(),
            CreateCurrency.RUB(),
            CreateCurrency.SAR(),
            CreateCurrency.SBD(),
            CreateCurrency.SEK(),
            CreateCurrency.SGD(),
            CreateCurrency.SZL(),
            CreateCurrency.THB(),
            CreateCurrency.TND(),
            CreateCurrency.TOP(),
            CreateCurrency.TRY(),
            CreateCurrency.UGX(),
            CreateCurrency.USD(),
            CreateCurrency.VUV(),
            CreateCurrency.WST(),
            CreateCurrency.XPF(),
            CreateCurrency.ZAR():
                ValidateRecordFields(Rec, CreateCHGLAccounts.UnrealizedExchRateAdjmts(), CreateCHGLAccounts.UnrealizedExchRateAdjmts());
            CreateCurrency.GBP():
                begin
                    ValidateRecordFields(Rec, CreateCHGLAccounts.UnrealizedExchRateAdjmts(), CreateCHGLAccounts.UnrealizedExchRateAdjmts());
                    Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
                end;
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record Currency; RealizedGainAcc: Code[20]; RealizedLossAcc: Code[20])
    begin
        Currency.Validate("Realized Gains Acc.", RealizedGainAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossAcc);
    end;
}