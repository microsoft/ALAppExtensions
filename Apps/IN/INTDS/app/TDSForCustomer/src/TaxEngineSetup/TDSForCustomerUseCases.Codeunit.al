// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

codeunit 18663 "TDS For Customer Use Cases"
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
        exit(TDSForCustomerUseCasesLbl);
    end;

    var
        TDSForCustomerUseCasesLbl: Label 'TDS For Customer Use Cases';
}
