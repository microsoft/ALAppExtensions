codeunit 17155 "Create AU Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

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
            CreateCurrency.RUB(),
            CreateCurrency.RSD(),
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
                UpdateCurrency(Rec, CreateGLAccount.RealizedFxGains(), CreateGLAccount.RealizedFxLosses(), CreateGLAccount.UnrealizedFxGains(), CreateGLAccount.UnrealizedFxLosses());
            CreateCurrency.GBP():
                begin
                    Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
                    UpdateCurrency(Rec, CreateGLAccount.RealizedFxGains(), CreateGLAccount.RealizedFxLosses(), CreateGLAccount.UnrealizedFxGains(), CreateGLAccount.UnrealizedFxLosses());
                end;
        end;
    end;

    local procedure UpdateCurrency(var Currency: Record Currency; RealizedGainsAcc: Code[20]; RealizedLossesAcc: Code[20]; UnrealizedGainsAcc: Code[20]; UnrealizedLossesAcc: Code[20])
    begin
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
        Currency.Validate("Unrealized Gains Acc.", UnrealizedGainsAcc);
        Currency.Validate("Unrealized Losses Acc.", UnrealizedLossesAcc);
    end;
}