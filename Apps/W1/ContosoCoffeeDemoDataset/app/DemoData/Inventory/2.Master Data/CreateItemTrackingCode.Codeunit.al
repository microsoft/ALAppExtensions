codeunit 5388 "Create Item Tracking Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemTrackingCode(FreeEntry(), FreeEntryofTrackingLbl, false, false, false, false, false, false);
        ContosoItem.InsertItemTrackingCode(LotAll(), LotSpecificTrackingLbl, false, true, false, false, false, false);
        ContosoItem.InsertItemTrackingCode(LotAllExp(), LotSpecificTrackingManualExpLbl, false, true, false, true, false, false);
        ContosoItem.InsertItemTrackingCode(LotSNSales(), LotSpecificSNSalesTrackingLbl, false, true, false, false, true, true);
        ContosoItem.InsertItemTrackingCode(SNAll(), SNSpecificTrackingLbl, true, false, false, false, false, false);
        ContosoItem.InsertItemTrackingCode(SNSales(), SNSalesTrackingLbl, false, false, false, false, true, true);
    end;

    procedure FreeEntry(): Code[10]
    begin
        exit(FreeEntryTok);
    end;

    procedure LotAll(): Code[10]
    begin
        exit(LotAllTok);
    end;

    procedure LotAllExp(): Code[10]
    begin
        exit(LotAllExpTok);
    end;

    procedure LotSNSales(): Code[10]
    begin
        exit(LotSNSalesTok);
    end;

    procedure SNAll(): Code[10]
    begin
        exit(SNAllTok);
    end;

    procedure SNSales(): Code[10]
    begin
        exit(SNSalesTok);
    end;

    var
        FreeEntryTok: Label 'FREEENTRY', Maxlength = 10;
        LotAllTok: Label 'LOTALL', Maxlength = 10;
        LotAllExpTok: Label 'LOTALLEXP', Maxlength = 10;
        LotSNSalesTok: Label 'LOTSNSALES', Maxlength = 10;
        SNAllTok: Label 'SNALL', Maxlength = 10;
        SNSalesTok: Label 'SNSALES', Maxlength = 10;
        FreeEntryofTrackingLbl: Label 'Free entry of tracking', Maxlength = 50;
        LotSpecificTrackingLbl: Label 'Lot specific tracking', Maxlength = 50;
        LotSpecificTrackingManualExpLbl: Label 'Lot specific tracking, manual Expiration', Maxlength = 50;
        LotSpecificSNSalesTrackingLbl: Label 'Lot specific SN Sales Tracking', Maxlength = 50;
        SNSpecificTrackingLbl: Label 'SN specific tracking', Maxlength = 50;
        SNSalesTrackingLbl: Label 'SN Sales tracking', Maxlength = 50;
}