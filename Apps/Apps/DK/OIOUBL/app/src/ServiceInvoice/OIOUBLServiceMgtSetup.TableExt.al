// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Setup;

tableextension 13654 "OIOUBL-Service Mgt. Setup" extends "Service Mgt. Setup"
{
    fields
    {
        field(13630; "OIOUBL-Service Invoice Path"; Text[250])
        {
            Caption = 'Service Invoice Path';
        }
        field(13631; "OIOUBL-Service Cr. Memo Path"; Text[250])
        {
            Caption = 'Service Cr. Memo Path';
        }
    }
    keys
    {
    }

    var
        SetupOIOUBLQst: Label 'OIOUBL path of the OIOMXL file is missing. Do you want to update it now?';
        MissingSetupOIOUBLErr: Label 'OIOUBL path of the OIOMXL file is missing. Please Correct it.';


    local procedure IsOIOUBLPathSetupAvailable("Document Type": Option Quote,Order,Invoice,"Credit Memo"): Boolean;
    begin
        case "Document Type" of
            "Document Type"::Order, "Document Type"::Invoice:
                exit("OIOUBL-Service Invoice Path" <> '');
            "Document Type"::"Credit Memo":
                exit("OIOUBL-Service Cr. Memo Path" <> '');
            else
                exit(TRUE);
        end;
    end;

    procedure OIOUBLVerifyAndSetPath("Document Type": Option Quote,Order,Invoice,"Credit Memo");
    var
        OIOUBLsetupPage: Page "Service Mgt. Setup";
    begin
        GET();
        if IsOIOUBLPathSetupAvailable("Document Type") then
            EXIT;

        if CONFIRM(SetupOIOUBLQst, TRUE) then begin
            OIOUBLsetupPage.SETRECORD(Rec);
            OIOUBLsetupPage.EDITABLE(TRUE);
            if OIOUBLsetupPage.RUNMODAL() = ACTION::OK then
                OIOUBLsetupPage.GETRECORD(Rec);
        end;

        if NOT IsOIOUBLPathSetupAvailable("Document Type") then
            ERROR(MissingSetupOIOUBLErr);
    end;
}
