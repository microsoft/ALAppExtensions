// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Common;
using Microsoft.FixedAssets.FixedAsset;

codeunit 5118 "Create Fixed Asset"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateFixedAsset();
        CreateMainAssetComponents();
        CreateFADepreciationBookForAssets();
    end;

    local procedure CreateFixedAsset()
    var
        FAClass: Codeunit "Create FA Class";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        FALocation: Codeunit "Create FA Location";
        CommonCustomerVendor: Codeunit "Create Common Customer/Vendor";
        ContosoUtilities: Codeunit "Contoso Utilities";
        DomesticVendor1, DomesticVendor2, DomesticVendor3 : Code[20];
    begin
        DomesticVendor1 := CommonCustomerVendor.DomesticVendor1();
        ContosoFixedAsset.InsertFixedAsset(FA000010(), Vehicle1Lbl, FAClass.TangibleClass(), FAClass.VehiclesSubClass(), FALocation.Administration(), Enum::"FA Component Type"::" ", SerialNoEA12394QLbl, ContosoUtilities.AdjustDate(19030412D), DomesticVendor1, DomesticVendor1);
        ContosoFixedAsset.InsertFixedAsset(FA000020(), Vehicle2Lbl, FAClass.TangibleClass(), FAClass.VehiclesSubClass(), FALocation.Sales(), Enum::"FA Component Type"::" ", SerialNoEA12395QLbl, ContosoUtilities.AdjustDate(19030718D), DomesticVendor1, DomesticVendor1);
        ContosoFixedAsset.InsertFixedAsset(FA000030(), Truck1Lbl, FAClass.TangibleClass(), FAClass.VehiclesSubClass(), FALocation.Production(), Enum::"FA Component Type"::" ", SerialNoEA15397QLbl, ContosoUtilities.AdjustDate(19030821D), DomesticVendor1, DomesticVendor1);

        DomesticVendor2 := CommonCustomerVendor.DomesticVendor2();
        ContosoFixedAsset.InsertFixedAsset(FA000040(), ConveyorMainAssetLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Production(), Enum::"FA Component Type"::"Main Asset", SerialNoX23111SW0Lbl, ContosoUtilities.AdjustDate(19030815D), DomesticVendor2, DomesticVendor2);
        ContosoFixedAsset.InsertFixedAsset(FA000050(), ConveyorBeltLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Production(), Enum::"FA Component Type"::Component, SerialNoX23111SW1Lbl, ContosoUtilities.AdjustDate(19030815D), DomesticVendor2, DomesticVendor2);
        ContosoFixedAsset.InsertFixedAsset(FA000060(), ConveyorComputerLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Production(), Enum::"FA Component Type"::Component, SerialNoX23111SW3Lbl, ContosoUtilities.AdjustDate(19030815D), DomesticVendor2, DomesticVendor2);

        DomesticVendor3 := CommonCustomerVendor.DomesticVendor3();
        ContosoFixedAsset.InsertFixedAsset(FA000070(), ConveyorLiftLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Production(), Enum::"FA Component Type"::Component, SerialNoX23111SW2Lbl, ContosoUtilities.AdjustDate(19030815D), DomesticVendor3, DomesticVendor3);
        ContosoFixedAsset.InsertFixedAsset(FA000080(), CargoLiftLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Production(), Enum::"FA Component Type"::" ", SerialNoAKW2476111Lbl, ContosoUtilities.AdjustDate(19030421D), DomesticVendor3, DomesticVendor3);
        ContosoFixedAsset.InsertFixedAsset(FA000090(), SwitchboardLbl, FAClass.TangibleClass(), FAClass.EquipmentSubClass(), FALocation.Administration(), Enum::"FA Component Type"::" ", SerialNoTELE4476ZLbl, ContosoUtilities.AdjustDate(19031212D), DomesticVendor3, DomesticVendor3);
    end;

    local procedure CreateMainAssetComponents()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertMainAssetComponent(FA000040(), FA000050());
        ContosoFixedAsset.InsertMainAssetComponent(FA000040(), FA000060());
        ContosoFixedAsset.InsertMainAssetComponent(FA000040(), FA000070());
    end;

    local procedure CreateFADepreciationBookForAssets()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoFixedAsset.InsertFADepreciationBook(FA000010(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(FA000020(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020501D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(FA000030(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020601D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(FA000040(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 0);
        ContosoFixedAsset.InsertFADepreciationBook(FA000050(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020101D), 10);
        ContosoFixedAsset.InsertFADepreciationBook(FA000060(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020201D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(FA000070(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020301D), 4);
        ContosoFixedAsset.InsertFADepreciationBook(FA000080(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020401D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(FA000090(), CreateFADepreciationBook.Company(), ContosoUtilities.AdjustDate(19020201D), 7);
    end;

    procedure FA000010(): Text[20]
    begin
        exit('FA000010');
    end;

    procedure FA000020(): Text[20]
    begin
        exit('FA000020');
    end;

    procedure FA000030(): Text[20]
    begin
        exit('FA000030');
    end;

    procedure FA000040(): Text[20]
    begin
        exit('FA000040');
    end;

    procedure FA000050(): Text[20]
    begin
        exit('FA000050');
    end;

    procedure FA000060(): Text[20]
    begin
        exit('FA000060');
    end;

    procedure FA000070(): Text[20]
    begin
        exit('FA000070');
    end;

    procedure FA000080(): Text[20]
    begin
        exit('FA000080');
    end;

    procedure FA000090(): Text[20]
    begin
        exit('FA000090');
    end;

    var
        Vehicle1Lbl: Label 'Vehicle 1', MaxLength = 100;
        Vehicle2Lbl: Label 'Vehicle 2', MaxLength = 100;
        Truck1Lbl: Label 'Truck 1', MaxLength = 100;
        ConveyorMainAssetLbl: Label 'Conveyor, Main Asset', MaxLength = 100;
        ConveyorBeltLbl: Label 'Conveyor Belt', MaxLength = 100;
        ConveyorComputerLbl: Label 'Conveyor Computer', MaxLength = 100;
        CargoLiftLbl: Label 'Cargo Lift', MaxLength = 100;
        ConveyorLiftLbl: Label 'Conveyor Lift', MaxLength = 100;
        SwitchboardLbl: Label 'Switchboard', MaxLength = 100;
        SerialNoEA12394QLbl: Label 'EA 12 394 Q', Locked = true;
        SerialNoEA12395QLbl: Label 'EA 12 395 Q', Locked = true;
        SerialNoEA15397QLbl: Label 'EA 15 397 Q', Locked = true;
        SerialNoX23111SW0Lbl: Label '23 111 SW0', Locked = true;
        SerialNoX23111SW1Lbl: Label '23 111 SW1', Locked = true;
        SerialNoX23111SW2Lbl: Label '23 111 SW2', Locked = true;
        SerialNoX23111SW3Lbl: Label '23 111 SW3', Locked = true;
        SerialNoAKW2476111Lbl: Label 'AKW2476111', Locked = true;
        SerialNoTELE4476ZLbl: Label 'TELE 4476 Z', Locked = true;
}
