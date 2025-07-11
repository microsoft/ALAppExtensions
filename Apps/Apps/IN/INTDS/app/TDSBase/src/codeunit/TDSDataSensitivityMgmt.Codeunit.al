// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TDS.TDSForCustomer;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.TDS.TDSReturnAndSettlement;
using Microsoft.Utilities;
using System.Privacy;

codeunit 18692 "TDS Data Sensitivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Act Applicable");
        SetTableFieldsToNormal(Database::"Allowed Sections");
        SetTableFieldsToNormal(Database::"TDS Concessional Code");
        SetTableFieldsToNormal(Database::"TDS Entry");
        SetTableFieldsToNormal(Database::"TDS Nature Of Remittance");
        SetTableFieldsToNormal(Database::"TDS Posting Setup");
        SetTableFieldsToNormal(Database::"TDS Setup");
        SetTableFieldsToNormal(Database::"Customer Allowed Sections");
        SetTableFieldsToNormal(Database::"TDS Customer Concessional Code");
        SetTableFieldsToNormal(Database::"Sales Header");
        SetTableFieldsToNormal(Database::"Gen. Journal Line");
        SetTableFieldsToNormal(Database::"Purchase Header");
        SetTableFieldsToNormal(Database::"Purchase Line");
        SetTableFieldsToNormal(Database::"Purch. Inv. Header");
        SetTableFieldsToNormal(Database::"Purch. Inv. Line");
        SetTableFieldsToNormal(Database::"TDS Challan Register");
        SetTableFieldsToNormal(Database::"TDS Journal Line");
        SetTableFieldsToNormal(Database::"TDS Journal Template");
        SetTableFieldsToNormal(Database::"Acknowledgement Setup");
        SetTableFieldsToNormal(Database::"TDS Section");
        SetTableFieldsToNormal(Database::"TDS Journal Batch")
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}
