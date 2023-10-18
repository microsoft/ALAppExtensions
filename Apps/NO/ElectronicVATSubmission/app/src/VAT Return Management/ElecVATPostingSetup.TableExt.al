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
#if not CLEAN23
        modify("Sales SAF-T Standard Tax Code")
        {
            trigger OnAfterValidate()
            begin
                CheckVATRateMatch("Sales SAF-T Standard Tax Code");
            end;
        }
        modify("Purch. SAF-T Standard Tax Code")
        {
            trigger OnAfterValidate()
            begin
                CheckVATRateMatch("Purch. SAF-T Standard Tax Code");
            end;
        }
#endif
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

#if not CLEAN23
    local procedure CheckVATRateMatch(VATCodeValue: Code[10])
    var
        VATCode: Record "VAT Code";
    begin
        if VATCodeValue = '' then
            exit;
        if not VATCode.Get(VATCodeValue) then
            exit;
        if not VATCode."Report VAT Rate" then
            exit;
        if VATCode."VAT Rate For Reporting" <> "VAT %" then
            Message(VATRateDoesNotMatchMsg, VATCode."VAT Rate For Reporting", "VAT %");
    end;
#endif

    var
        VATRateDoesNotMatchMsg: Label 'The VAT code you have selected has a VAT rate for reporting (%1 %) that is different than a VAT rate in the VAT posting setup (%2)', Comment = '%1,%2 = VAT rates/numbers';
}
