#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using System.Upgrade;

codeunit 10554 "Upgrade Reverse Charge VAT"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagReverseChargeVAT: Codeunit "Upg. Tag Reverse Charge VAT";

    trigger OnUpgradePerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 30 then
            exit;

        UpgradeReverseChargeVAT();
    end;

    local procedure UpgradeReverseChargeVAT()
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagReverseChargeVAT.GetReverseChargeVATUpgradeTag()) then
            exit;

        TransferFields(Database::"General Ledger Setup", 10507, 10500); // 10507 - the new field "Threshold applies GB", 10500;  the existing field "Threshold applies"; 
        TransferFields(Database::"General Ledger Setup", 10508, 10501); // 10508 - the new field "Threshold Amount GB", 10501;  the existing field "Threshold Amount"; 
        TransferFields(Database::Item, 10507, 10500); // 10507 - the new field "Reverse Charge Applies GB", 10500;  the existing field "Reverse Charge Applies"; 
        TransferFields(Database::"Item Templ.", 10507, 10500); // 10507 - the new field "Reverse Charge Applies GB", 10500;  the existing field "Reverse Charge Applies"; 
        TransferFields(Database::"Purchase Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Purchases & Payables Setup", 10507, 10501); // 10507 - the new field "Reverse Charge VAT Post. Gr.", 10501;  the existing field "Reverse Charge VAT Posting Gr."; 
        TransferFields(Database::"Purchases & Payables Setup", 10508, 10502); // 10508 - the new field "Domestic Vendors GB", 10502;  the existing field "Domestic Vendors"; 
        TransferFields(Database::"Purch. Cr. Memo Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Purch. Cr. Memo Line", 10508, 10501); // 10508 - the new field "Reverse Charge GB", 10501;  the existing field "Reverse Charge"; 
        TransferFields(Database::"Purch. Inv. Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Purch. Inv. Line", 10508, 10501); // 10508 - the new field "Reverse Charge GB", 10501;  the existing field "Reverse Charge"; 
        TransferFields(Database::"Sales Cr.Memo Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Sales Cr.Memo Line", 10508, 10501); // 10508 - the new field "Reverse Charge GB", 10501;  the existing field "Reverse Charge"; 
        TransferFields(Database::"Sales Invoice Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Sales Invoice Line", 10508, 10501); // 10508 - the new field "Reverse Charge GB", 10501;  the existing field "Reverse Charge"; 
        TransferFields(Database::"Sales Line", 10507, 10500); // 10507 - the new field "Reverse Charge Item GB", 10500;  the existing field "Reverse Charge Item"; 
        TransferFields(Database::"Sales Line", 10508, 10501); // 10508 - the new field "Reverse Charge GB", 10501;  the existing field "Reverse Charge"; 
        TransferFields(Database::"Sales & Receivables Setup", 10507, 10501); // 10507 - the new field "Reverse Charge VAT Post. Gr.", 10501;  the existing field "Reverse Charge VAT Posting Gr."; 
        TransferFields(Database::"Sales & Receivables Setup", 10508, 10502); // 10508 - the new field "Domestic Customers GB", 10502;  the existing field "Domestic Customers"; 
        TransferFields(Database::"Sales & Receivables Setup", 10509, 10503); // 10509 - the new field "Invoice Wording GB", 10503;  the existing field "Invoice Wording"; 
        TransferFields(Database::"VAT Amount Line", 10507, 10500); // 10507 - the new field "Reverse Charge GB", 10500;  the existing field "Reverse Charge"; 

        UpgradeTag.SetUpgradeTag(UpgTagReverseChargeVAT.GetReverseChargeVATUpgradeTag());
    end;

    local procedure TransferFields(TableId: Integer; SourceFieldNo: Integer; TargetFieldNo: Integer)
    var
        RecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
    begin
        RecRef.Open(TableId, false);
        SourceFieldRef := RecRef.Field(SourceFieldNo);
        SourceFieldRef.SetFilter('<>%1', '');

        if RecRef.FindSet() then
            repeat
                TargetFieldRef := RecRef.Field(TargetFieldNo);
                TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                RecRef.Modify(false);
            until RecRef.Next() = 0;
    end;
}
#endif