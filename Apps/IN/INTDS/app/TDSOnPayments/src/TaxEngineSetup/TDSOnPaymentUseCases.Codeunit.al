// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPayments;

codeunit 18770 "TDS On Payment Use Cases"
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
        exit(TDSOnPaymentsUseCasesLbl);
    end;

    var
        TDSOnPaymentsUseCasesLbl: Label 'TDS on Payment Use Cases';
}
