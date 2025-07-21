// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Upgrade;

using Microsoft;
using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Assembly.Setup;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Setup;
using System.Environment.Configuration;

codeunit 31251 "Upgrade Application CZA"
{
    Subtype = Upgrade;
    Permissions = tabledata "Assembly Setup" = m,
                  tabledata "Assembly Header" = m,
                  tabledata "Assembly Line" = m,
                  tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m,
                  tabledata "Posted Assembly Header" = m,
                  tabledata "Posted Assembly Line" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Item Entry Relation" = m,
                  tabledata "Standard Item Journal Line" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZA: Codeunit "Upgrade Tag Definitions CZA";
        InstallApplicationsCZA: Codeunit "Install Application CZA";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsCZA);
        UpgradeDefaultBusinessPostingGroup();
        UpgradePostedDefaultBusinessPostingGroup();
        UnbindSubscription(InstallApplicationsCZA);
    end;

    local procedure UpgradeDefaultBusinessPostingGroup()
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        AssemblySetup: Record "Assembly Setup";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyHeaderDataTransfer: DataTransfer;
        AssemblyLineDataTransfer: DataTransfer;

    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDefaultBusinessPostingGroupUpgradeTag()) then
            exit;

        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Default Gen. Bus. Post. Group" := ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA";
            ManufacturingSetup.Modify();
        end;

        if AssemblySetup.Get() then begin
            AssemblySetup."Default Gen. Bus. Post. Group" := AssemblySetup."Default Gen.Bus.Post. Grp. CZA";
            AssemblySetup.Modify();
        end;

        AssemblyHeaderDataTransfer.SetTables(Database::"Assembly Header", Database::"Assembly Header");
        AssemblyHeaderDataTransfer.AddFieldValue(AssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"), AssemblyHeader.FieldNo("Gen. Bus. Posting Group"));
        AssemblyHeaderDataTransfer.CopyFields();

        AssemblyLineDataTransfer.SetTables(Database::"Assembly Line", Database::"Assembly Line");
        AssemblyLineDataTransfer.AddFieldValue(AssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"), AssemblyLine.FieldNo("Gen. Bus. Posting Group"));
        AssemblyLineDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDefaultBusinessPostingGroupUpgradeTag());
    end;

    local procedure UpgradePostedDefaultBusinessPostingGroup()
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyLine: Record "Posted Assembly Line";
        PostedAssemblyHeaderDataTransfer: DataTransfer;
        PostedAssemblyLineDataTransfer: DataTransfer;

    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetPostedDefaultBusinessPostingGroupUpgradeTag()) then
            exit;

        PostedAssemblyHeaderDataTransfer.SetTables(Database::"Posted Assembly Header", Database::"Posted Assembly Header");
        PostedAssemblyHeaderDataTransfer.AddFieldValue(PostedAssemblyHeader.FieldNo("Gen. Bus. Posting Group CZA"), PostedAssemblyHeader.FieldNo("Gen. Bus. Posting Group"));
        PostedAssemblyHeaderDataTransfer.CopyFields();

        PostedAssemblyLineDataTransfer.SetTables(Database::"Posted Assembly Line", Database::"Posted Assembly Line");
        PostedAssemblyLineDataTransfer.AddFieldValue(PostedAssemblyLine.FieldNo("Gen. Bus. Posting Group CZA"), PostedAssemblyLine.FieldNo("Gen. Bus. Posting Group"));
        PostedAssemblyLineDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetPostedDefaultBusinessPostingGroupUpgradeTag());
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion200PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion220PerDatabaseUpgradeTag());
    end;
}
