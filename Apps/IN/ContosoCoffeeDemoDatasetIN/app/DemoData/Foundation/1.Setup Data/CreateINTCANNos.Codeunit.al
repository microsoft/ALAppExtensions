// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19014 "Create IN TCAN Nos."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertTCANNos(BlueTCANNo(), BlueTCANNoLbl);
        ContosoINTaxSetup.InsertTCANNos(RedTCANNo(), RedTCANNoLbl);
    end;

    procedure BlueTCANNo(): Code[10]
    begin
        exit(BlueTCANNoTok);
    end;

    procedure RedTCANNo(): Code[10]
    begin
        exit(RedTCANNoTok);
    end;

    var
        BlueTCANNoTok: Label 'DELN03830B', MaxLength = 10;
        RedTCANNoTok: Label 'RED0897580', MaxLength = 10;
        BlueTCANNoLbl: Label 'BLUE Location', MaxLength = 50;
        RedTCANNoLbl: Label 'Red Location', MaxLength = 50;
}
