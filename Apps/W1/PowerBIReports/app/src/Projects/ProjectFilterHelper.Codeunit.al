// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.PowerBIReports;

using Microsoft.PowerBIReports;

codeunit 36956 "Project Filter Helper"
{
    Access = Internal;

    procedure GenerateJobLedgerDateFilter(): Text
    var
        PBISetup: Record "PowerBI Reports Setup";
        FilterRangeLbl: Label '%1..%2', Locked = true;
        FilterTxt: Text;
    begin
        if PBISetup.Get() then begin
            if (PBISetup."Job Ledger Entry Start Date" = 0D) and (PBISetup."Job Ledger Entry End Date" = 0D) then
                exit('');
            FilterTxt := StrSubstNo(FilterRangeLbl, Format(PBISetup."Job Ledger Entry Start Date"), Format(PBISetup."Job Ledger Entry End Date"));
            exit(FilterTxt);
        end;
        exit('');
    end;
}