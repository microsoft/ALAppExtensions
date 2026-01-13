// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;

tableextension 10526 "VAT Report Archive" extends "VAT Report Archive"
{
    var
        XMLPartID: Guid;
        DummyGuid: Boolean;

    procedure SetXMLPartID(ID: Guid)
    begin
        XMLPartID := ID;
    end;

    procedure GetXMLPartID(): Guid
    begin
        exit(XMLPartID);
    end;

    procedure IsDummyGuid(): Boolean
    begin
        exit(DummyGuid);
    end;

    procedure SetDummyGuid(EmptyGuid: Boolean)
    begin
        DummyGuid := EmptyGuid;
    end;
}