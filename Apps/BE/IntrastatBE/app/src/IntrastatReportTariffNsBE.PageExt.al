// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11350 "Intrastat Report Tariff Ns. BE" extends "Tariff Numbers"
{
    layout
    {
        modify("Conversion Factor")
        {
            Visible = OldFieldsEnabled;
            Enabled = OldFieldsEnabled;
        }
        modify("Unit of Measure")
        {
            Visible = OldFieldsEnabled;
            Enabled = OldFieldsEnabled;
        }
    }
    trigger OnOpenPage()
    begin
        OldFieldsEnabled := not IntrastatReportMgt.IsFeatureEnabled();
    end;

    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        [InDataSet]
        OldFieldsEnabled: Boolean;
}