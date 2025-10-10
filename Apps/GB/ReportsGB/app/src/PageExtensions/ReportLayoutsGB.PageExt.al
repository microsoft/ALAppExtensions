#pragma warning disable AS0029
#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Shared.Report;

pageextension 10580 "Report Layouts GB" extends "Report Layouts"
{

    ObsoleteTag = '28.0';
    ObsoleteReason = 'The functionality is enforced.';
    ObsoleteState = Pending;
    trigger OnOpenPage()
    var
        ReportsGB: Codeunit "Reports GB";
    begin
        if not ReportsGB.IsEnabled() then
            Rec.SetFilter(Name, '<>GBlocalizationLayout');
    end;
}
#endif
#pragma warning restore AS0029