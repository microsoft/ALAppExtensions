// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPurchase;

codeunit 18718 "TDS On Purchase Use Cases"
{
    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(TDSOnPurchaseUseCasesLbl);
    end;

    var
        TDSOnPurchaseUseCasesLbl: Label 'TDS On Purchase Use Cases';
}
