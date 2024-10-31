// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.Core;

using Microsoft.Utilities;
using System.Privacy;

codeunit 20135 "Symbol Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifySymbolSpecificTables()
    begin
        ClassifyTablesToNormal();
        ClassifyCompanyConfidentialFields();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Script Symbol");
        SetTableFieldsToNormal(Database::"Lookup Field Filter");
        SetTableFieldsToNormal(Database::"Script Symbol Lookup");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;

    local procedure ClassifyCompanyConfidentialFields()
    var
        ScriptSymbolValue: Record "Script Symbol Value";
        ScriptSymbolMemberValue: Record "Script Symbol Member Value";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        SetTableFieldsToNormal(Database::"Script Symbol Value");
        SetTableFieldsToNormal(Database::"Script Symbol Member Value");
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Script Symbol Value", ScriptSymbolValue.FieldNo("RecordID Value"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Script Symbol Member Value", ScriptSymbolMemberValue.FieldNo("RecordID Value"));
    end;
}
