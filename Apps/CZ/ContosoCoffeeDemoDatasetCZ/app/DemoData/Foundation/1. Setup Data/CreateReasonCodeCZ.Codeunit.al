// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 31190 "Create Reason Code CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoReasonCodeCZ: Codeunit "Contoso Reason Code CZ";
    begin
        ContosoReasonCodeCZ.InsertReasonCode(Liquid(), LiquidDescriptionLbl);
        ContosoReasonCodeCZ.InsertReasonCode(Sale(), SaleDescriptionLbl);
    end;

    procedure Liquid(): Code[10]
    begin
        exit(LIQUIDLbl);
    end;

    procedure Sale(): Code[10]
    begin
        exit(SALELbl);
    end;

    var
        LIQUIDLbl: Label 'LIQUID', MaxLength = 10;
        SALELbl: Label 'SALE', MaxLength = 10;
        LiquidDescriptionLbl: Label 'Liquidation', MaxLength = 100;
        SaleDescriptionLbl: Label 'Sale', MaxLength = 100;
}
