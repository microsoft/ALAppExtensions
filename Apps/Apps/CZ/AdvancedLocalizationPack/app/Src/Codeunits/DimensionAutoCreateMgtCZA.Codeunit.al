// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Dimension;

using Microsoft.Bank.BankAccount;
using Microsoft.CashFlow.Setup;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Insurance;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Reflection;
using System.Utilities;

codeunit 31394 "Dimension Auto.Create Mgt. CZA"
{
    procedure AutoCreateDimension(TableID: Integer; No: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AutoDefaultDimension: Record "Default Dimension";
        NewDefaultDimension: Record "Default Dimension";
        NewDimensionValue: Record "Dimension Value";
        Employee: Record Employee;
        Item: Record Item;
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        ResourceGroup: Record "Resource Group";
        Resource: Record Resource;
        Job: Record Job;
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        Insurance: Record Insurance;
        ResponsibilityCenter: Record "Responsibility Center";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Campaign: Record Campaign;
        CashFlowManualExpense: Record "Cash Flow Manual Expense";
        CashFlowManualRevenue: Record "Cash Flow Manual Revenue";
        VendorTempl: Record "Vendor Templ.";
        CustomerTempl: Record "Customer Templ.";
        ItemTempl: Record "Item Templ.";
        EmployeeTempl: Record "Employee Templ.";
        WorkCenter: Record "Work Center";
        ItemCharge: Record "Item Charge";
        DimensionAutoUpdateMgtCZA: Codeunit "Dimension Auto.Update Mgt. CZA";
        IsHandled: Boolean;
    begin
        OnBeforeAutoCreateDimension(TableID, No, IsHandled);
        if IsHandled then
            exit;

        GeneralLedgerSetup.Get();
        AutoDefaultDimension.SetRange("Table ID", TableID);
        AutoDefaultDimension.SetRange("No.", '');
        AutoDefaultDimension.SetRange("Automatic Create CZA", true);
        if AutoDefaultDimension.FindSet() then
            repeat
                if not NewDimensionValue.Get(AutoDefaultDimension."Dimension Code", No) then begin
                    NewDimensionValue.Init();
                    NewDimensionValue."Dimension Code" := AutoDefaultDimension."Dimension Code";
                    NewDimensionValue.Code := No;
                    if (AutoDefaultDimension."Dim. Description Field ID CZA" = 0) or
                       (AutoDefaultDimension."Dim. Description Update CZA" in
                        [AutoDefaultDimension."Dim. Description Update CZA"::" "])
                    then
                        NewDimensionValue.Name := No;
                    NewDimensionValue."Dimension Value Type" := NewDimensionValue."Dimension Value Type"::Standard;
                    if NewDimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then
                        NewDimensionValue."Global Dimension No." := 1;
                    if NewDimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then
                        NewDimensionValue."Global Dimension No." := 2;
                    if NewDimensionValue.Insert(true) then;
                end;

                NewDefaultDimension.Init();
                NewDefaultDimension."Table ID" := TableID;
                NewDefaultDimension."No." := No;
                NewDefaultDimension."Dimension Code" := AutoDefaultDimension."Dimension Code";
                NewDefaultDimension."Dimension Value Code" := NewDimensionValue.Code;
                NewDefaultDimension."Value Posting" := AutoDefaultDimension."Auto. Create Value Posting CZA";
                if NewDefaultDimension.Insert(true) then;

                case TableID of
                    Database::Item:
                        if not Item.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunItemOnAfterInsertEvent(true);
                    Database::Customer:
                        if not Customer.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunCustomerOnAfterInsertEvent(true);
                    Database::Vendor:
                        if not Vendor.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunVendorOnAfterInsertEvent(true);
                    Database::Employee:
                        if not Employee.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeOnAfterInsertEvent(true);
                    Database::"G/L Account":
                        if not GLAccount.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunGLAccountOnAfterInsertEvent(true);
                    Database::"Resource Group":
                        if not ResourceGroup.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunResourceGroupOnAfterInsertEvent(true);
                    Database::Resource:
                        if not Resource.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunResourceOnAfterInsertEvent(true);
                    Database::Job:
                        if not Job.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunJobOnAfterInsertEvent(true);
                    Database::"Bank Account":
                        if not BankAccount.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunBankAccountOnAfterInsertEvent(true);
                    Database::"Fixed Asset":
                        if not FixedAsset.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunFixedAssetOnAfterInsertEvent(true);
                    Database::Insurance:
                        if not Insurance.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunInsuranceOnAfterInsertEvent(true);
                    Database::"Responsibility Center":
                        if not ResponsibilityCenter.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunResponsibilityCenterOnAfterInsertEvent(true);
                    Database::"Salesperson/Purchaser":
                        if not SalespersonPurchaser.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunSalespersonPurchaserOnAfterInsertEvent(true);
                    Database::Campaign:
                        if not Campaign.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunCampaignOnAfterInsertEvent(true);
                    Database::"Cash Flow Manual Expense":
                        if not CashFlowManualExpense.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunCashFlowManualExpenseOnAfterInsertEvent(true);
                    Database::"Cash Flow Manual Revenue":
                        if not CashFlowManualRevenue.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunCashFlowManualRevenueOnAfterInsertEvent(true);
                    Database::"Vendor Templ.":
                        if not VendorTempl.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunVendorTemplOnAfterInsertEvent(true);
                    Database::"Customer Templ.":
                        if not CustomerTempl.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunCustomerTemplOnAfterInsertEvent(true);
                    Database::"Item Templ.":
                        if not ItemTempl.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunItemTemplOnAfterInsertEvent(true);
                    Database::"Employee Templ.":
                        if not EmployeeTempl.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeTemplOnAfterInsertEvent(true);
                    Database::"Work Center":
                        if not WorkCenter.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunWorkCenterOnAfterInsertEvent(true);
                    Database::"Item Charge":
                        if not ItemCharge.Get(No) then
                            DimensionAutoUpdateMgtCZA.SetRequestRunItemChargeOnAfterInsertEvent(true);
                end;
            until AutoDefaultDimension.Next() = 0;
    end;

    procedure UpdateAllAutomaticDimValues(var DefaultDimension: Record "Default Dimension")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NewDefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        RecField: Record "Field";
        ConfirmManagement: Codeunit "Confirm Management";
        MasterRecordRef: RecordRef;
        DescriptionFieldRef: FieldRef;
        PrimaryKeyFieldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        TempValueText: Text;
        InitDimQst: Label 'Do you want to initialize dimensions of the selected tables? This may take some time and you cannot undo your changes. Do you really want to continue?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(InitDimQst, false) then
            Error('');

        GeneralLedgerSetup.Get();
        DefaultDimension.SetRange("Automatic Create CZA", true);
        DefaultDimension.SetRange("No.", '');
        if DefaultDimension.FindSet(false) then
            repeat
                Clear(MasterRecordRef);
                MasterRecordRef.Open(DefaultDimension."Table ID");
                if MasterRecordRef.FindSet() then
                    repeat
                        PrimaryKeyRef := MasterRecordRef.KeyIndex(1);
                        PrimaryKeyFieldRef := PrimaryKeyRef.FieldIndex(1);
                        if not DimensionValue.Get(DefaultDimension."Dimension Code", Format(PrimaryKeyFieldRef.Value)) then begin
                            DimensionValue.Init();
                            DimensionValue."Dimension Code" := DefaultDimension."Dimension Code";
                            DimensionValue.Code := Format(PrimaryKeyFieldRef.Value);
                            if (DefaultDimension."Dim. Description Field ID CZA" = 0) or
                               (DefaultDimension."Dim. Description Update CZA" = DefaultDimension."Dim. Description Update CZA"::" ")
                            then
                                DimensionValue.Name := Format(PrimaryKeyFieldRef.Value);
                            DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
                            if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then
                                DimensionValue."Global Dimension No." := 1;
                            if DimensionValue."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then
                                DimensionValue."Global Dimension No." := 2;
                            if DimensionValue.Insert(true) then;
                        end;
                        if (DefaultDimension."Dim. Description Field ID CZA" <> 0) and
                           (DefaultDimension."Dim. Description Update CZA" <> DefaultDimension."Dim. Description Update CZA"::" ")
                        then begin
                            DescriptionFieldRef := MasterRecordRef.Field(DefaultDimension."Dim. Description Field ID CZA");
                            if RecField.Get(DefaultDimension."Table ID", DefaultDimension."Dim. Description Field ID CZA") then
                                if RecField.Class = RecField.Class::FlowField then
                                    DescriptionFieldRef.CalcField();
                            TempValueText := Format(DescriptionFieldRef.Value);
                            if DefaultDimension."Dim. Description Format CZA" <> '' then
                                TempValueText := StrSubstNo(DefaultDimension."Dim. Description Format CZA", TempValueText);
                            if TempValueText <> '' then
                                TempValueText := CopyStr(TempValueText, 1, MaxStrLen(DimensionValue.Name));
                            if DimensionValue.Name <> TempValueText then begin
                                DimensionValue.Name := CopyStr(TempValueText, 1, MaxStrLen(DimensionValue.Name));
                                DimensionValue.Modify();
                            end;
                        end;
                        if not NewDefaultDimension.Get(DefaultDimension."Table ID", Format(PrimaryKeyFieldRef.Value), DefaultDimension."Dimension Code") then begin
                            NewDefaultDimension.Init();
                            NewDefaultDimension."Table ID" := DefaultDimension."Table ID";
                            NewDefaultDimension."No." := Format(PrimaryKeyFieldRef.Value);
                            NewDefaultDimension."Dimension Code" := DefaultDimension."Dimension Code";
                            NewDefaultDimension."Dimension Value Code" := DimensionValue.Code;
                            NewDefaultDimension."Value Posting" := DefaultDimension."Auto. Create Value Posting CZA";
                            if NewDefaultDimension.Insert(true) then;
                        end;
                    until MasterRecordRef.Next() = 0;
            until DefaultDimension.Next() = 0;
    end;

    internal procedure CreateAndSendSignOutNotification()
    var
        SignOutDimensionNotification: Notification;
        SignOutMsg: Label 'Changed settings will take effect for you immediately, for other users only after they log in again.';
    begin
        SignOutDimensionNotification.Message := SignOutMsg;
        SignOutDimensionNotification.Scope := NotificationScope::LocalScope;
        SignOutDimensionNotification.Send();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoCreateDimension(TableID: Integer; No: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
