// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.FixedAssets.FixedAsset;

codeunit 31185 "Create FA Posting Group CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAssetCZ: Codeunit "Contoso Fixed Asset CZ";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        ContosoFixedAssetCZ.InsertFAPostingGroup(Furniture(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofmachinesandtools(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Internalsettlement());
        ContosoFixedAssetCZ.InsertFAPostingGroup(Patents(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofpatents(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Intangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Internalsettlement());
        ContosoFixedAssetCZ.InsertFAPostingGroup(Software(), CreateGLAccount.Software(), CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccount.Software(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccount.Software(), CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccount.Software(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofsoftware(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccount.Software(), CreateGLAccount.Software(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Internalsettlement());
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofmachinesandtools(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Machinestoolsequipment(), CreateGLAccountCZ.Acquisitionofmachinery(), CreateGLAccountCZ.Internalsettlement());
            CreateFAPostingGroup.Goodwill():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofotherintangiblefixedassets(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Goodwill(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Internalsettlement());
            CreateFAPostingGroup.Plant():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofbuildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Internalsettlement());
            CreateFAPostingGroup.Property():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofbuildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Buildings(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Internalsettlement());
            CreateFAPostingGroup.Vehicles():
                ValidateFAPostingGroup(Rec, CreateGLAccount.Vehicles(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccount.Vehicles(), CreateGLAccountCZ.Acquisitionofvehicles(), CreateGLAccount.Vehicles(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccount.Vehicles(), CreateGLAccountCZ.Acquisitionofintangiblefixedassets(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetsdisposed(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.Netbookvalueoffixedassetssold(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountCZ.Depreciationofvehicles(), CreateGLAccountCZ.Acquisitionofvehicles(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccount.Vehicles(), CreateGLAccount.Vehicles(), CreateGLAccountCZ.Acquisitionofvehicles(), CreateGLAccountCZ.Internalsettlement());
        end;
    end;

    local procedure ValidateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group"; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; WriteDownAccount: Code[20]; Custom2Account: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; WriteDownAccOnDisposal: Code[20]; Custom2AccountOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20];
                                   SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20]; ApprecBalAccOnDisp: Code[20]; AppreciationAccOnDisposal: Code[20]; AppreciationAccount: Code[20]; AppreciationBalAccount: Code[20]; SalesBalAcc: Code[20])
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Write-Down Account", WriteDownAccount);
        FAPostingGroup.Validate("Custom 2 Account", Custom2Account);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Write-Down Acc. on Disposal", WriteDownAccOnDisposal);
        FAPostingGroup.Validate("Custom 2 Account on Disposal", Custom2AccountOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
        FAPostingGroup.Validate("Apprec. Bal. Acc. on Disp.", ApprecBalAccOnDisp);
        FAPostingGroup.Validate("Appreciation Acc. on Disposal", AppreciationAccOnDisposal);
        FAPostingGroup.Validate("Appreciation Account", AppreciationAccount);
        FAPostingGroup.Validate("Appreciation Bal. Account", AppreciationBalAccount);
        FAPostingGroup.Validate("Sales Bal. Acc.", SalesBalAcc);
    end;

    procedure Furniture(): Code[20]
    begin
        exit(FurnitureLbl);
    end;

    procedure Patents(): Code[20]
    begin
        exit(PatentsLbl);
    end;

    procedure Software(): Code[20]
    begin
        exit(SoftwareLbl);
    end;

    var
        FurnitureLbl: Label 'FURNITURE', MaxLength = 20;
        PatentsLbl: Label 'PATENTS', MaxLength = 20;
        SoftwareLbl: Label 'SOFTWARE', MaxLength = 20;
}
