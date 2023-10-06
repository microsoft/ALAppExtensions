// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 5281 "Source Code SAF-T"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Source Code';

    fields
    {
        field(1; Code; Code[9]) { }
        field(2; Description; Text[100]) { }
        field(3; "Includes No Source Code"; Boolean)
        {
            trigger OnValidate()
            var
                SourceCodeSAFT: Record "Source Code SAF-T";
            begin
                if "Includes No Source Code" then begin
                    SourceCodeSAFT.SetFilter(Code, '<>%1', Code);
                    SourceCodeSAFT.SetRange("Includes No Source Code", true);
                    if SourceCodeSAFT.FindFirst() then
                        Error(IncludeNoSourceCodeAlreadyExistErr, SourceCodeSAFT.Code);
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
        IncludeNoSourceCodeAlreadyExistErr: label 'SAF-T source code %1 already has the Include No Source Code enabled. You cannot set this option for multiple SAF-T source codes.', Comment = '%1 = SAF-T source code no, like GL,AR,AP and so on';

}
