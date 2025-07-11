// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Reporting;

tableextension 10689 "Elec. VAT Posting Setup" extends "VAT Posting Setup"
{

    fields
    {
        modify("Sale VAT Reporting Code")
        {
            trigger OnAfterValidate()
            begin
                CheckIfVATRateMatch("Sale VAT Reporting Code");
            end;
        }
        modify("Purch. VAT Reporting Code")
        {
            trigger OnAfterValidate()
            begin
                CheckIfVATRateMatch("Purch. VAT Reporting Code");
            end;
        }
    }

    local procedure CheckIfVATRateMatch(VATCodeValue: Code[20])
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        if VATCodeValue = '' then
            exit;
        if not VATReportingCode.Get(VATCodeValue) then
            exit;
        if not VATReportingCode."Report VAT Rate" then
            exit;
        if VATReportingCode."VAT Rate For Reporting" <> "VAT %" then
            Message(VATRateDoesNotMatchMsg, VATReportingCode."VAT Rate For Reporting", "VAT %");
    end;

    var
        VATRateDoesNotMatchMsg: Label 'The VAT code you have selected has a VAT rate for reporting (%1 %) that is different than a VAT rate in the VAT posting setup (%2)', Comment = '%1,%2 = VAT rates/numbers';
}
