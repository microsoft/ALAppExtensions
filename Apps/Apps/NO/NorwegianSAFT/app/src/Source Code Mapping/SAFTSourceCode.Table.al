// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 10681 "SAF-T Source Code"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Source Code';

    fields
    {
        field(1; Code; Code[9])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Includes No Source Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Includes No Source Code';

            trigger OnValidate()
            var
                SAFTSourceCode: Record "SAF-T Source Code";
            begin
                if "Includes No Source Code" then begin
                    SAFTSourceCode.SetFilter(Code, '<>%1', Code);
                    SAFTSourceCode.SetRange("Includes No Source Code", true);
                    if SAFTSourceCode.FindFirst() then
                        Error(IncludeNoSourceCodeAlreadyExistErr, SAFTSourceCode.Code);
                end;
            end;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        IncludeNoSourceCodeAlreadyExistErr: Label 'SAF-T source code %1 already has the Include No Source Code enabled.. You cannot set this option for multiple SAF-T source codes', Comment = '%1 = SAF-T source code no, like GL,AR,AP and so on';

}
