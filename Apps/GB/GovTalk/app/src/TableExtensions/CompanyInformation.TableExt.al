// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Foundation.Company;

tableextension 10504 "Company Information" extends "Company Information"
{
    fields
    {
        field(10509; "Branch Number GB"; Text[3])
        {
            Caption = 'Branch Number';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Branch Number GB" <> '' then
                    if StrLen("Branch Number GB") < MaxStrLen("Branch Number GB") then
                        FieldError("Branch Number GB", StrSubstNo(Text10500Err, MaxStrLen("Branch Number GB")));
            end;
        }
    }

    var
        Text10500Err: Label 'must be a %1 digit numeric number', Comment = '%1 = branch number';
}