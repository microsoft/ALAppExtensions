// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Inventory.Location;

codeunit 19002 "Create IN Location"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateINState: Codeunit "Create IN State";
        CreateINTCANNos: Codeunit "Create IN TCAN Nos.";
        CreateINTANNos: Codeunit "Create IN TAN Nos.";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        ContosoInventory.InsertLocation(BlueLocation(), BlueLocationDescLbl, BlueLocationAddressLbl, '', BlueLocationCityLbl, BlueLocationPhoneLbl, BlueLocationFaxLbl, BlueLocationContactLbl, BlueLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
        ContosoInventory.InsertLocation(RedLocation(), RedLocationDescLbl, RedLocationAddressLbl, '', RedLocationCityLbl, RedLocationPhoneLbl, RedLocationFaxLbl, RedLocationContactLbl, RedLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
        UpdateTaxInformationOnLocation(BlueLocation(), CreateINState.Delhi(), '07COMPA0007I1Z1', CreateINTANNos.BlueTANNo(), CreateINTCANNos.BlueTCANNo());
        UpdateTaxInformationOnLocation(RedLocation(), CreateINState.Haryana(), '06COMPA0007I1Z1', CreateINTANNos.RedTANNo(), CreateINTCANNos.RedTCANNo());
    end;

    local procedure UpdateTaxInformationOnLocation(LocationCode: Code[10]; StateCode: Code[10]; GSTRegistrationNo: Code[20]; TANNo: Code[10]; TCANNo: Code[10])
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then begin
            Location.Validate("State Code", StateCode);
            Location."GST Registration No." := GSTRegistrationNo;
            Location.Validate("T.A.N. No.", TANNo);
            Location.Validate("T.C.A.N. No.", TCANNo);
            Location.Modify(true);
        end;
    end;

    procedure BlueLocation(): Code[10]
    begin
        exit(BlueLocationTok);
    end;

    procedure RedLocation(): Code[10]
    begin
        exit(RedLocationTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertLocation(var Rec: Record Location)
    var
        CreateLocaion: Codeunit "Create Location";
    begin
        case Rec.Code of
            CreateLocaion.EastLocation():
                ValidateRecordFields(Rec, JackPotterLbl, EastLocationPostCodeLbl);
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, OscarGreenwoodLbl, WestLocationPostCodeLbl);
            CreateLocaion.MainLocation():
                ValidateRecordFields(Rec, EleanorParkesLbl, MainLocationPostCodeLbl);
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Contact: Text[100]; PostCode: Code[20])
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CreateCountryRegion.GB();
    end;

    var
        JackPotterLbl: Label 'Jack Potter', MaxLength = 100;
        EleanorParkesLbl: Label 'Eleanor Parkes', MaxLength = 100;
        OscarGreenwoodLbl: Label 'Oscar Greenwood', MaxLength = 100;
        EastLocationPostCodeLbl: Label 'GB-EC2A 3JL', MaxLength = 20;
        MainLocationPostCodeLbl: Label 'GB-RG6 1WG', MaxLength = 20;
        WestLocationPostCodeLbl: Label 'GB-NP10 8BE', MaxLength = 20;
        BlueLocationTok: Label 'BLUE', MaxLength = 10;
        RedLocationTok: Label 'RED', MaxLength = 10;
        BlueLocationDescLbl: Label 'Blue Warehouse', MaxLength = 100;
        RedLocationDescLbl: Label 'Red Warehouse', MaxLength = 100;
        BlueLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        RedLocationAddressLbl: Label 'Main Ashford Street, 2', MaxLength = 100, Locked = true;
        BlueLocationCityLbl: Label 'NEW DELHI', MaxLength = 30, Locked = true;
        RedLocationCityLbl: Label 'GURUGRAM', MaxLength = 30, Locked = true;
        BlueLocationPhoneLbl: Label '+44-(0)20 8207 4533', MaxLength = 30, Locked = true;
        RedLocationPhoneLbl: Label '+44-(0)50 1424 0001', MaxLength = 30, Locked = true;
        BlueLocationFaxLbl: Label '+44-(0)20 8207 5000', MaxLength = 30, Locked = true;
        RedLocationFaxLbl: Label '+44-(0)50 1424 0002', MaxLength = 30, Locked = true;
        BlueLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        RedLocationContactLbl: Label 'Carole Poland', MaxLength = 100;
        BlueLocationPostCodeLbl: Label 'IN-110001', MaxLength = 20;
        RedLocationPostCodeLbl: Label 'IN-122002', MaxLength = 20;
}
