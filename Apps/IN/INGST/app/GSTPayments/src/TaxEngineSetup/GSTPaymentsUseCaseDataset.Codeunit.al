// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

codeunit 18250 "GST Payments UseCase Dataset"
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
        exit(GSTOnPaymentUseCasesLbl);
    end;

    var
        GSTOnPaymentUseCasesLbl: Label 'GST On Payment Use Cases';
}
