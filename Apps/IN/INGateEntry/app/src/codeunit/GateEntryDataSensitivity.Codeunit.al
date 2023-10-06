// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Inventory.Setup;
using Microsoft.Sales.Document;
using Microsoft.Utilities;
using System.Privacy;

codeunit 18605 "Gate Entry Data Sensitivity"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Gate Entry Header");
        SetTableFieldsToNormal(Database::"Gate Entry Line");
        SetTableFieldsToNormal(Database::"Gate Entry Comment Line");
        SetTableFieldsToNormal(Database::"Service Entity Type");
        SetTableFieldsToNormal(Database::"Sales Header");
        SetTableFieldsToNormal(Database::"Inventory Setup");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}
