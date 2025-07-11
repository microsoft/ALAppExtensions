// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TCS.TCSReturnAndSettlement;
using Microsoft.Sales.Document;
using Microsoft.Utilities;
using System.Privacy;

codeunit 18813 "TCS Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Allowed NOC");
        SetTableFieldsToNormal(Database::"Customer Concessional Code");
        SetTableFieldsToNormal(Database::"T.C.A.N. No.");
        SetTableFieldsToNormal(Database::"TCS Entry");
        SetTableFieldsToNormal(Database::"TCS Nature Of Collection");
        SetTableFieldsToNormal(Database::"TCS Posting Setup");
        SetTableFieldsToNormal(Database::"TCS Setup");
        SetTableFieldsToNormal(Database::"Sales Header");
        SetTableFieldsToNormal(Database::"Sales Line");
        SetTableFieldsToNormal(Database::"TCS Challan Register");
        SetTableFieldsToNormal(Database::"TCS Journal Batch");
        SetTableFieldsToNormal(Database::"TCS Journal Line");
        SetTableFieldsToNormal(Database::"TCS Journal Template");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}
