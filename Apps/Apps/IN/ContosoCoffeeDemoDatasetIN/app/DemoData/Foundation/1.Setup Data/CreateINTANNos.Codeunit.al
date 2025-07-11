// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19013 "Create IN TAN Nos."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertTANNos(BlueTANNo(), BlueTANNoLbl);
        ContosoINTaxSetup.InsertTANNos(RedTANNo(), RedTANNoLbl);
    end;

    procedure BlueTANNo(): Code[10]
    begin
        exit(BlueTANNoTok);
    end;

    procedure RedTANNo(): Code[10]
    begin
        exit(RedTANNoTok);
    end;

    var
        BlueTANNoTok: Label 'BLU0897580', MaxLength = 10;
        RedTANNoTok: Label 'REDN03830B', MaxLength = 10;
        BlueTANNoLbl: Label 'BLUE Location', MaxLength = 50;
        RedTANNoLbl: Label 'Red Location', MaxLength = 50;
}
