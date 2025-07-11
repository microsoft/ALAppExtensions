// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Dimension;

using Microsoft.Finance.AuditFileExport;

tableextension 10678 "SAF-T Analysis" extends Dimension
{
    fields
    {
        field(10670; "SAF-T Analysis Type"; Code[9])
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T Analysis Type';
        }
        field(10671; "Export to SAF-T"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Export to SAF-T';
            InitValue = true;
        }
    }

    procedure UpdateSAFTAnalysisTypeFromNoSeries()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if not SAFTSetup.Get() then
            exit;
        SAFTSetup.Validate("Dimension No.", SAFTSetup."Dimension No." + 1);
        Validate("SAF-T Analysis Type", Format(SAFTSetup."Dimension No."));
        SAFTSetup.Modify(true);
    end;

}
