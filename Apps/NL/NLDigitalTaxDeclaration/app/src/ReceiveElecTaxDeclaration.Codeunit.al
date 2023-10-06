// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 11424 "Receive Elec. Tax Declaration"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        ElecTaxDeclResponseMsg: Record "Elec. Tax Decl. Response Msg.";
    begin
        ElecTaxDeclResponseMsg.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
        ElecTaxDeclResponseMsg.SetRange("VAT Report No.", "No.");
        PAGE.Run(PAGE::"Elec. Tax Decl. Response Msgs.", ElecTaxDeclResponseMsg);
    end;
}

