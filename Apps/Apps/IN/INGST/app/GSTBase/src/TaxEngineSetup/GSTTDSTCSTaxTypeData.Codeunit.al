// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

codeunit 18012 "GST TDS TCS Tax Type Data"
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
        exit(GSTTDSTCSTaxTypeLbl);
    end;

    var
        GSTTDSTCSTaxTypeLbl: Label 'GST TDS TCS Tax Type place holder';
}
