// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using System.Privacy;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Utilities;

codeunit 18639 "FA Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"FA Accounting Period Inc. Tax");
        SetTableFieldsToNormal(Database::"Fixed Asset Block");
        SetTableFieldsToNormal(Database::"Depreciation Book");
        SetTableFieldsToNormal(Database::"Fixed Asset Shift");
        SetTableFieldsToNormal(Database::"FA Depreciation Book");
        SetTableFieldsToNormal(Database::"FA Journal Line");
        SetTableFieldsToNormal(Database::"FA Ledger Entry");
        SetTableFieldsToNormal(Database::"Fixed Asset");
        SetTableFieldsToNormal(Database::"Gen. Journal Line");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}
