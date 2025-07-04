// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using System.Telemetry;

page 5548 "Contoso Modules Part"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Contoso Demo Data Module";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Available Modules';
    RefreshOnActivate = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Editable = false;
                    ToolTip = 'Specifies the demo data module name';
                }
                field(Install; Rec.Install)
                {
                    Editable = true;
                    ToolTip = 'Specifies the demo data module installation level. It indicates which data was included and can vary between "Setup Data," meaning that only settings and configurations were installed, or "All," in which case setup, master data, transactions, and history were installed.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        FeatureTelemetry.LogUptake('0000NFD', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
        ContosoDemoTool.GetRefreshedModules(Rec);
        Rec.ModifyAll(Install, true);
        FeatureTelemetry.LogUptake('0000NFE', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    internal procedure GetContosoRecord(var ContosoDemoDataModuleTemp: Record "Contoso Demo Data Module" temporary)
    var
    begin
        if Rec.FindSet() then
            repeat
                ContosoDemoDataModuleTemp.TransferFields(Rec);
                ContosoDemoDataModuleTemp.Insert();
            until Rec.Next() = 0;
    end;

    internal procedure SetContosoRecord(var ContosoDemoDataModuleTemp: Record "Contoso Demo Data Module" temporary)
    var
    begin
        if ContosoDemoDataModuleTemp.FindSet() then
            repeat
                Rec.Get(ContosoDemoDataModuleTemp.Module);
                Rec.Install := ContosoDemoDataModuleTemp.Install;
                Rec.Modify();
            until ContosoDemoDataModuleTemp.Next() = 0;
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
}
