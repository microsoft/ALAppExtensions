// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13659 "OIOUBL-Company Information" extends "Company Information"
{
    var
        MissingOIOUBMInfoQst: Label 'You need to provide information in %1 to support OIOUBL. Do you want to update it now?', Comment = '%1 = Company Information caption';
        MissingOIOUBMInfoErr: Label 'The needed information to support OIOUBL is not provided in %1.', Comment = '%1 = Company Information caption';

    procedure OIOUBLVerifyAndSetInfo();
    var
        OIOUBLCompanyInfoSetup: Page "OIOUBL-Company Info. Setup";
    begin
        GET();
        if IsOIOUBLInfoAvailable() then
            EXIT;
        if CONFIRM(MissingOIOUBMInfoQst, TRUE, TABLECAPTION()) then begin
            OIOUBLCompanyInfoSetup.SETRECORD(Rec);
            OIOUBLCompanyInfoSetup.EDITABLE(TRUE);
            if OIOUBLCompanyInfoSetup.RUNMODAL() = ACTION::OK then
                OIOUBLCompanyInfoSetup.GETRECORD(Rec);
            if NOT IsOIOUBLInfoAvailable() then
                ERROR(MissingOIOUBMInfoErr, TABLECAPTION())
        end else
            ERROR(MissingOIOUBMInfoErr, TABLECAPTION());
    end;

    local procedure IsOIOUBLInfoAvailable(): Boolean;
    begin
        if "VAT Registration No." = '' then
            exit(FALSE);
        if Name = '' then
            exit(FALSE);
        if Address = '' then
            exit(FALSE);
        if City = '' then
            exit(FALSE);
        if "Post Code" = '' then
            exit(FALSE);
        if "Country/Region Code" = '' then
            exit(FALSE);
        if IBAN = '' then
            if "Bank Account No." = '' then
                exit(FALSE);
        if "Bank Branch No." = '' then
            exit(FALSE);
        exit(TRUE);
    end;

    procedure GetOIOUBLPaymentChannelCode(): Text;
    var
        CountryRegion: Record 9;
    begin
        CountryRegion.GET("Country/Region Code");
        CountryRegion.TESTFIELD("OIOUBL-Country/Region Code");
        exit(CountryRegion."OIOUBL-Country/Region Code" + ':BANK');
    end;
}