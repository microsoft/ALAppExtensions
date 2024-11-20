codeunit 13716 "Create Currency DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrency(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCurrency.AED(),
            CreateCurrency.AUD(),
            CreateCurrency.BGN(),
            CreateCurrency.BND(),
            CreateCurrency.BRL(),
            CreateCurrency.CAD(),
            CreateCurrency.CHF(),
            CreateCurrency.CZK(),
            CreateCurrency.DKK(),
            CreateCurrency.DZD(),
            CreateCurrency.EUR(),
            CreateCurrency.FJD(),
            CreateCurrency.GBP(),
            CreateCurrency.HKD(),
            CreateCurrency.HUF(),
            CreateCurrency.HRK(),
            CreateCurrency.IDR(),
            CreateCurrency.INR(),
            CreateCurrency.ISK(),
            CreateCurrency.JPY(),
            CreateCurrency.KES(),
            CreateCurrency.MAD(),
            CreateCurrency.MXN(),
            CreateCurrency.MYR(),
            CreateCurrency.MZN(),
            CreateCurrency.NOK(),
            CreateCurrency.NZD(),
            CreateCurrency.NGN(),
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
            CreateCurrency.TRY(),
            CreateCurrency.TOP(),
            CreateCurrency.UGX(),
            CreateCurrency.USD(),
            CreateCurrency.VUV(),
            CreateCurrency.WST(),
            CreateCurrency.XPF(),
            CreateCurrency.ZAR():
                ValidateRecordFields(Rec, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.RealizedFXGains(), CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.RealizedFXLosses());
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record Currency; UnrealizedGainsAcc: Code[20]; RealizedGainsAcc: Code[20]; UnrealizedLossesAcc: Code[20]; RealizedLossesAcc: Code[20])
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        if Currency.Code = CreateCurrency.GBP() then
            Currency."Unit-Amount Rounding Precision" := 0.00001;

        Currency.Validate("Unrealized Gains Acc.", UnrealizedGainsAcc);
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Unrealized Losses Acc.", UnrealizedLossesAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
    end;
}