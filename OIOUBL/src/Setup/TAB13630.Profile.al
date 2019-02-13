// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 13630 "OIOUBL-Profile"
{
    DrillDownPageID = "OIOUBL-Profile List";
    LookupPageID = "OIOUBL-Profile List";
    ReplicateData = false;

    fields
    {
        field(13630; "OIOUBL-Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(13631; "OIOUBL-Profile ID"; Text[50])
        {
            Caption = 'Profile';
        }
    }

    keys
    {
        key(Key1; "OIOUBL-Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(AllFields; "OIOUBL-Code", "OIOUBL-Profile ID")
        {
        }
    }

    var
        DeleteErr: Label 'At least one OIOUBL profile needs to exist.';

    trigger OnDelete()
    begin
        if Count() <= 1 then
            Error(DeleteErr);
    end;

    procedure GetOIOUBLProfileID(OIOUBLProfileCode: Code[10]; CustomerNo: Code[20]): Text;
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
        SalesSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
    begin
        if OIOUBLProfileCode = '' then begin
            Customer.GET(CustomerNo);
            OIOUBLProfileCode := Customer."OIOUBL-Profile Code";
            if OIOUBLProfileCode = '' then begin
                SalesSetup.GET();
                SalesSetup.TESTFIELD("OIOUBL-Default Profile Code");
                OIOUBLProfileCode := SalesSetup."OIOUBL-Default Profile Code";
            end;
        end;

        OIOUBLProfile.GET(OIOUBLProfileCode);
        OIOUBLProfile.TESTFIELD("OIOUBL-Profile ID");

        exit(OIOUBLProfile."OIOUBL-Profile ID");
    end;

    procedure UpdateEmptyOIOUBLProfileCodes(OIOUBLProfileCode: Code[10]; PrevOIOUBLProfileCode: Code[10]);
    var
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
    begin
        if (OIOUBLProfileCode <> PrevOIOUBLProfileCode) AND (PrevOIOUBLProfileCode = '') then begin
            SalesHeader.SETRANGE("OIOUBL-Profile Code", '');
            SalesHeader.MODIFYALL("OIOUBL-Profile Code", OIOUBLProfileCode);

            ServiceHeader.SETRANGE("OIOUBL-Profile Code", '');
            ServiceHeader.MODIFYALL("OIOUBL-Profile Code", OIOUBLProfileCode);
        end;
    end;
}