codeunit 17115 "Create NZ Shipping Agent"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoShipping: codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShippingAgent(NZPost(), NZPostNameLbl, NZPostInternetAddressLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Shipping Agent", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Shipping Agent")
    var
        CreateShippingData: Codeunit "Create Shipping Data";
    begin
        case Rec.Code of
            CreateShippingData.DHL():
                ValidateRecordFields(Rec, DHLNameLbl);
            CreateShippingData.Fedex():
                ValidateRecordFields(Rec, FedexNameLbl);
            CreateShippingData.UPS():
                ValidateRecordFields(Rec, UPSNameLbl);
        end;
    end;

    procedure NZPost(): Code[10]
    begin
        exit(NZPostTok);
    end;

    local procedure ValidateRecordFields(var ShippingAgent: Record "Shipping Agent"; Name: Text[100])
    begin
        ShippingAgent.Validate(Name, Name);
    end;

    var
        NZPostTok: Label 'NZPOST', MaxLength = 10, Comment = 'Company Code', Locked = true;
        NZPostNameLbl: Label 'NZ Post', MaxLength = 50, Comment = 'Company Name', Locked = true;
        DHLNameLbl: Label 'DHL Systems, Inc. NZ', MaxLength = 50, Comment = 'Company Name', Locked = true;
        FedexNameLbl: Label 'Federal Express Corporation NZ', MaxLength = 50, Comment = 'Company Name', Locked = true;
        UPSNameLbl: Label 'UPS - Fliway (NZ) Ltd', MaxLength = 50, Comment = 'Company Name', Locked = true;
        NZPostInternetAddressLbl: Label 'www.nzpost.co.nz/Cultures/en-NZ/OnlineTools/TrackAndTrace', MaxLength = 250, Comment = 'URL', Locked = true;
}