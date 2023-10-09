// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

codeunit 18084 "GST Purchase UseCase Dataset"
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
        exit(GSTOnPurchaseUseCasesLbl);
    end;

    var
        GSTOnPurchaseUseCasesLbl: Label 'GST On Purchase Use Cases.';
}
