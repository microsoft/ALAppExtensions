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
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Resources.Resource;
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
        if DimensionAutoUpdateMgtCZA.IsRequestRunItemOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Item, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure CustomerOnAfterInsertEvent(var Rec: Record Customer)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCustomerOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Customer, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure VendorOnAfterInsertEvent(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunVendorOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Vendor, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterInsertEvent', '', false, false)]
    local procedure EmployeeOnAfterInsertEvent(var Rec: Record Employee)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunEmployeeOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Employee, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure GLAccountOnAfterInsertEvent(var Rec: Record "G/L Account")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunGLAccountOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"G/L Account", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Resource Group", 'OnAfterInsertEvent', '', false, false)]
    local procedure ResourceGroupOnAfterInsertEvent(var Rec: Record "Resource Group")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunResourceOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Resource Group", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterInsertEvent', '', false, false)]
    local procedure ResourceOnAfterInsertEvent(var Rec: Record Resource)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunResourceOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Resource, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsertEvent(var Rec: Record Job)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunJobOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Job, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure BankAccountOnAfterInsertEvent(var Rec: Record "Bank Account")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunBankAccountOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Bank Account", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnAfterInsertEvent', '', false, false)]
    local procedure FixedAssetOnAfterInsertEvent(var Rec: Record "Fixed Asset")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunFixedAssetOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Fixed Asset", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Insurance, 'OnAfterInsertEvent', '', false, false)]
    local procedure InsuranceOnAfterInsertEvent(var Rec: Record Insurance)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunInsuranceOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Insurance, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Responsibility Center", 'OnAfterInsertEvent', '', false, false)]
    local procedure ResponsibilityCenterOnAfterInsertEvent(var Rec: Record "Responsibility Center")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunResponsibilityCenterOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Responsibility Center", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterInsertEvent', '', false, false)]
    local procedure SalespersonPurchaserOnAfterInsertEvent(var Rec: Record "Salesperson/Purchaser")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunSalespersonPurchaserOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Salesperson/Purchaser", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Campaign, 'OnAfterInsertEvent', '', false, false)]
    local procedure CampaignOnAfterInsertEvent(var Rec: Record Campaign)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCampaignOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::Campaign, Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Flow Manual Expense", 'OnAfterInsertEvent', '', false, false)]
    local procedure CashFlowManualExpenseOnAfterInsertEvent(var Rec: Record "Cash Flow Manual Expense")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCashFlowManualExpenseOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Cash Flow Manual Expense", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Flow Manual Revenue", 'OnAfterInsertEvent', '', false, false)]
    local procedure CashFlowManualRevenueOnAfterInsertEvent(var Rec: Record "Cash Flow Manual Revenue")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCashFlowManualRevenueOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Cash Flow Manual Revenue", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnAfterInsertEvent', '', false, false)]
    local procedure VendorTemplOnAfterInsertEvent(var Rec: Record "Vendor Templ.")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunVendorTemplOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Vendor Templ.", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnAfterInsertEvent', '', false, false)]
    local procedure CustomerTemplOnAfterInsertEvent(var Rec: Record "Customer Templ.")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCustomerTemplOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Customer Templ.", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Templ.", 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemTemplOnAfterInsertEvent(var Rec: Record "Item Templ.")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunItemTemplOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Item Templ.", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Employee Templ.", 'OnAfterInsertEvent', '', false, false)]
    local procedure EmployeeTemplOnAfterInsertEvent(var Rec: Record "Employee Templ.")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunEmployeeTemplOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Employee Templ.", Rec.Code);
            Rec.Get(Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Work Center", 'OnAfterInsertEvent', '', false, false)]
    local procedure WorkCenterOnAfterInsertEvent(var Rec: Record "Work Center")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunWorkCenterOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Work Center", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemChargeOnAfterInsertEvent(var Rec: Record "Item Charge")
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunItemChargeOnAfterInsertEventDefaultDim() then begin
            UpdateDefaultDimension(Database::"Item Charge", Rec."No.");
            Rec.Get(Rec."No.");
        end;
    end;

    local procedure UpdateDefaultDimension(TableID: Integer; No: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DefaultDimension: Record "Default Dimension";
    begin
        GeneralLedgerSetup.Get();
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        if DefaultDimension.FindSet(true) then
            repeat
                if DefaultDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then
                    DefaultDimension.UpdateGlobalDimCode(1, TableID, No, DefaultDimension."Dimension Value Code");
                if DefaultDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then
                    DefaultDimension.UpdateGlobalDimCode(2, TableID, No, DefaultDimension."Dimension Value Code");
                DefaultDimension.UpdateReferencedIds();
            until DefaultDimension.Next() = 0;

        SetRequestRunFalse(TableID);
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

    local procedure SetRequestRunFalse(TableID: Integer)
    begin
        case TableID of
            Database::Customer:
                DimensionAutoUpdateMgtCZA.SetRequestRunCustomerOnAfterInsertEvent(false);
            Database::Vendor:
                DimensionAutoUpdateMgtCZA.SetRequestRunVendorOnAfterInsertEvent(false);
            Database::Item:
                DimensionAutoUpdateMgtCZA.SetRequestRunItemOnAfterInsertEvent(false);
            Database::Employee:
                DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeOnAfterInsertEvent(false);
            Database::"G/L Account":
                DimensionAutoUpdateMgtCZA.SetRequestRunGLAccountOnAfterInsertEvent(false);
            Database::"Resource Group":
                DimensionAutoUpdateMgtCZA.SetRequestRunResourceOnAfterInsertEvent(false);
            Database::Resource:
                DimensionAutoUpdateMgtCZA.SetRequestRunResourceOnAfterInsertEvent(false);
            Database::Job:
                DimensionAutoUpdateMgtCZA.SetRequestRunJobOnAfterInsertEvent(false);
            Database::"Bank Account":
                DimensionAutoUpdateMgtCZA.SetRequestRunBankAccountOnAfterInsertEvent(false);
            Database::"Fixed Asset":
                DimensionAutoUpdateMgtCZA.SetRequestRunFixedAssetOnAfterInsertEvent(false);
            Database::Insurance:
                DimensionAutoUpdateMgtCZA.SetRequestRunInsuranceOnAfterInsertEvent(false);
            Database::"Responsibility Center":
                DimensionAutoUpdateMgtCZA.SetRequestRunResponsibilityCenterOnAfterInsertEvent(false);
            Database::"Salesperson/Purchaser":
                DimensionAutoUpdateMgtCZA.SetRequestRunSalespersonPurchaserOnAfterInsertEvent(false);
            Database::Campaign:
                DimensionAutoUpdateMgtCZA.SetRequestRunCampaignOnAfterInsertEvent(false);
            Database::"Cash Flow Manual Expense":
                DimensionAutoUpdateMgtCZA.SetRequestRunCashFlowManualExpenseOnAfterInsertEvent(false);
            Database::"Cash Flow Manual Revenue":
                DimensionAutoUpdateMgtCZA.SetRequestRunCashFlowManualRevenueOnAfterInsertEvent(false);
            Database::"Vendor Templ.":
                DimensionAutoUpdateMgtCZA.SetRequestRunVendorTemplOnAfterInsertEvent(false);
            Database::"Customer Templ.":
                DimensionAutoUpdateMgtCZA.SetRequestRunCustomerTemplOnAfterInsertEvent(false);
            Database::"Item Templ.":
                DimensionAutoUpdateMgtCZA.SetRequestRunItemTemplOnAfterInsertEvent(false);
            Database::"Employee Templ.":
                DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeTemplOnAfterInsertEvent(false);
            Database::"Work Center":
                DimensionAutoUpdateMgtCZA.SetRequestRunWorkCenterOnAfterInsertEvent(false);
            Database::"Item Charge":
                DimensionAutoUpdateMgtCZA.SetRequestRunItemChargeOnAfterInsertEvent(false);
        end;
    end;

    var
        DimensionAutoUpdateMgtCZA: Codeunit "Dimension Auto.Update Mgt. CZA";
}
