// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnSales;

codeunit 18840 "TCS On Sales Use Cases"
{
    var
        TCSOnSalesUseCasesLbl: Label 'TCS on Sales Use Cases';

    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(TCSOnSalesUseCasesLbl);
    end;
}
