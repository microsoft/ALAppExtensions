// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.AuditCodes;

codeunit 17159 "Create AU Source Code Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSourceCodeSetup();
    end;

    local procedure UpdateSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        CreateAUSourceCode: Codeunit "Create AU Source Code";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("WHT Settlement", CreateAUSourceCode.WithholdingTaxStatement());
        SourceCodeSetup.Modify(true);
    end;
}
