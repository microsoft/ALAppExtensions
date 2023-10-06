// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

tableextension 11290 "SE Company Information" extends "Company Information"
{

    fields
    {
        field(11290; "Plus Giro Number"; Text[20])
        {
            Caption = 'Plus Giro No.';
        }
        field(11291; "Registered Office Info"; Text[20])
        {
            Caption = 'Registered Office';
        }
    }

    var
        BoardOfDirectorsLocCaptionLbl: Label 'Board Of Directors Location (registered office)';

    procedure GetLegalOfficeLabel(): Text
    begin
        exit(BoardOfDirectorsLocCaptionLbl);
    end;
}
