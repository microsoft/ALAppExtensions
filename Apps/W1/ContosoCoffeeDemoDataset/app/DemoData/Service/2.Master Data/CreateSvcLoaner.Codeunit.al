// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Service;

using Microsoft.DemoTool.Helpers;

codeunit 5111 "Create Svc Loaner"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SvcDemoDataSetup: Record "Service Module Setup";
        LOANERTok: Label 'LOANER', MaxLength = 10;

    trigger OnRun()
    var
        ContosoService: Codeunit "Contoso Service";
    begin
        SvcDemoDataSetup.Get();

        ContosoService.InsertLoaner(Loaner(), SvcDemoDataSetup."Item 1 No.");
    end;

    procedure Loaner(): Code[10]
    begin
        exit(LOANERTok);
    end;
}
