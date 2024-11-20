codeunit 11525 "Create Freely Transfer Max. NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateCurrency: Codeunit "Create Currency";
    begin
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.AT(), '', 12500);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.BE(), '', 9000);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.CH(), CreateCurrency.CHF(), 18000);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.DE(), '', 12500);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.DK(), CreateCurrency.DKK(), 21500);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.EL(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.ES(), '', 12500);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.FI(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.FR(), '', 12500);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.GB(), CreateCurrency.GBP(), 8000);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.IE(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.IS(), CreateCurrency.ISK(), 208000);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.IT(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.LU(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.NO(), CreateCurrency.NOK(), 23300);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.PT(), '', 2900);
        ContosoBankNL.InsertFreelyTransferableMaximum(CreateCountryRegion.SE(), CreateCurrency.SEK(), 24300);
    end;

    var
}