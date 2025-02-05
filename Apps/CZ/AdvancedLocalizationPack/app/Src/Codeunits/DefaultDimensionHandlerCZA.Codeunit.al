// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Dimension;

using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 31392 "Default Dimension Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure TestAutomaticCreateOnAfterValidateNo(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if Rec."No." <> '' then
            Rec.TestField(Rec."Automatic Create CZA", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Value Posting', false, false)]
    local procedure TestAutomaticCreateOnAfterValidateValuePosting(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if not (Rec."Value Posting" in [Rec."Value Posting"::"Code Mandatory", Rec."Value Posting"::"Same Code"]) then
            Rec.TestField(Rec."Automatic Create CZA", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure AutomaticCreateOnAfterModifyEvent(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension")
    begin
        if Rec."Automatic Create CZA" then
            DimensionAutoUpdateMgtCZA.ForceSetDimChangeSetupRead();
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemOnAfterInsertEvent(var Rec: Record Item)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunItemOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Item, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure CustomerOnAfterInsertEvent(var Rec: Record Customer)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCustomerOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Customer, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure VendorOnAfterInsertEvent(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunVendorOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Vendor, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterInsertEvent', '', false, false)]
    local procedure EmployeeOnAfterInsertEvent(var Rec: Record Employee)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunEmployeeOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Employee, Rec."No.")
    end;

    local procedure UpdateReferenceIds(TableID: Integer; No: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        if DefaultDimension.FindSet(true) then
            repeat
                DefaultDimension.UpdateReferencedIds()
            until DefaultDimension.Next() = 0;

        case TableID of
            Database::Customer:
                DimensionAutoUpdateMgtCZA.SetRequestRunCustomerOnAfterInsertEvent(false);
            Database::Vendor:
                DimensionAutoUpdateMgtCZA.SetRequestRunVendorOnAfterInsertEvent(false);
            Database::Item:
                DimensionAutoUpdateMgtCZA.SetRequestRunItemOnAfterInsertEvent(false);
            Database::Employee:
                DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeOnAfterInsertEvent(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnCopyDefaultDimensionsFromCustomerOnBeforeUpdateDefaultDim', '', false, false)]
    local procedure JobOnCopyDefaultDimensionsFromCustomerOnBeforeUpdateDefaultDim(var Job: Record Job)
    var
        JobDefaultDimension: Record "Default Dimension";
        AutoDefaultDimension: Record "Default Dimension";
        NewDimensionValue: Record "Dimension Value";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        AutoDefaultDimension.SetRange("Table ID", Database::Job);
        AutoDefaultDimension.SetRange("No.", '');
        AutoDefaultDimension.SetRange("Automatic Create CZA", true);
        if AutoDefaultDimension.FindSet() then
            repeat
                if NewDimensionValue.Get(AutoDefaultDimension."Dimension Code", Job."No.") then
                    if not JobDefaultDimension.Get(Database::Job, Job."No.", AutoDefaultDimension."Dimension Code") then begin
                        JobDefaultDimension.Init();
                        JobDefaultDimension."Table ID" := Database::Job;
                        JobDefaultDimension."No." := Job."No.";
                        JobDefaultDimension."Dimension Code" := AutoDefaultDimension."Dimension Code";
                        JobDefaultDimension."Dimension Value Code" := NewDimensionValue.Code;
                        JobDefaultDimension."Value Posting" := AutoDefaultDimension."Auto. Create Value Posting CZA";
                        JobDefaultDimension.Insert();
                        DimensionManagement.DefaultDimOnInsert(JobDefaultDimension);
                    end;
            until AutoDefaultDimension.Next() = 0;
    end;

    var
        DimensionAutoUpdateMgtCZA: Codeunit "Dimension Auto.Update Mgt. CZA";
}
