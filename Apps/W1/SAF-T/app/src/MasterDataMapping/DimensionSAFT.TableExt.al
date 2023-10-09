// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;

tableextension 5282 "Dimension SAF-T" extends Dimension
{
    fields
    {
        field(5280; "Analysis Type SAF-T"; Code[9])
        {
            Caption = 'SAF-T Analysis Type';
        }
        field(5281; "SAF-T Export"; Boolean)
        {
            InitValue = true;
        }
    }

    procedure UpdateSAFTAnalysisTypeFromNoSeries()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        if not AuditFileExportSetup.Get() then
            exit;
        AuditFileExportSetup.Validate("Dimension No.", AuditFileExportSetup."Dimension No." + 1);
        Validate("Analysis Type SAF-T", Format(AuditFileExportSetup."Dimension No."));
        AuditFileExportSetup.Modify(true);
    end;

}
