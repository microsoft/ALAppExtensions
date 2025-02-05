codeunit 17115 "Create AU Shipping Agent"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoShipping: Codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShippingAgent(AUPost(), AUPostNameLbl, AUPostInternetAddressLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipping Agent", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record "Shipping Agent"; RunTrigger: Boolean)
    var
        CreateShippingData: Codeunit "Create Shipping Data";
    begin
        case Rec.Code of
            CreateShippingData.DHL():
                ValidateRecordFields(Rec, DHLNameLbl);
            CreateShippingData.Fedex():
                ValidateRecordFields(Rec, FEDEXNameLbl);
            CreateShippingData.UPS():
                ValidateRecordFields(Rec, UPSNameLbl);
        end;
    end;

    local procedure ValidateRecordFields(var ShippingAgent: Record "Shipping Agent"; Name: Text[50])
    begin
        ShippingAgent.Validate(Name, Name);
    end;

    procedure AUPost(): Code[10]
    begin
        exit(AUPostTok);
    end;

    var
        AUPostTok: Label 'AUPOST', MaxLength = 10;
        DHLNameLbl: Label 'DHL Systems, Inc. AU', MaxLength = 50;
        FEDEXNameLbl: Label 'Federal Express Corporation AU', MaxLength = 50;
        UPSNameLbl: Label 'UPS Australia P/L', MaxLength = 50;
        AUPostNameLbl: Label 'AU Post Express Courier International', MaxLength = 50;
        AUPostInternetAddressLbl: Label 'ice.auspost.com.au', MaxLength = 250, Comment = 'URL', Locked = true;
}