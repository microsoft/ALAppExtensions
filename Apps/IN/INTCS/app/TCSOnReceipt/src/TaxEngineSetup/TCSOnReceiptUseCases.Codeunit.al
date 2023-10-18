// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnReceipt;

codeunit 18902 "TCS On Receipt Use Cases"
{
    var
        TCSOnReceiptUseCasesLbl: Label 'TCS on Receipt Use Cases';

    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(TCSOnReceiptUseCasesLbl);
    end;
}
