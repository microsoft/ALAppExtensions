// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

codeunit 18395 "GST Stock UseCase Dataset"
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
        exit(GSTOnStockTransferUseCasesLbl);
    end;

    procedure GetTreeJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetTreeText());
        exit(JObject);
    end;

    procedure GetTreeText(): Text
    begin
        exit(UseCaseTreeLbl);
    end;

    var
        GSTOnStockTransferUseCasesLbl: Label 'GST On Stock Transfer Use Cases';
        UseCaseTreeLbl: Label 'Old Use Case Tree Place holder';
}
