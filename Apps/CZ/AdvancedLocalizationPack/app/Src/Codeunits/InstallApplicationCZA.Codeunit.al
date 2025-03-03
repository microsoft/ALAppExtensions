// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft;

using Microsoft.Assembly.Document;
using Microsoft.Assembly.History;
using Microsoft.Assembly.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Setup;
using Microsoft.Utilities;
using System.Environment;
using System.Upgrade;

#pragma warning disable AL0432
codeunit 31250 "Install Application CZA"
{
    EventSubscriberInstance = Manual;
    Subtype = Install;
    Permissions = tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m,
                  tabledata "Assembly Setup" = m,
                  tabledata "Assembly Header" = m,
                  tabledata "Assembly Line" = m,
                  tabledata "Posted Assembly Header" = m,
                  tabledata "Posted Assembly Line" = m,
                  tabledata "Nonstock Item Setup" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Capacity Ledger Entry" = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Transfer Route" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Receipt Line" = m,
                  tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Item Entry Relation" = m,
                  tabledata "Default Dimension" = m,
                  tabledata "Standard Item Journal Line" = m;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZA: Codeunit "Data Class. Eval. Handler CZA";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZA.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseInsert', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseInsert(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseModify', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseModify(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseDelete', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseDelete(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseRename', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseRename(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
