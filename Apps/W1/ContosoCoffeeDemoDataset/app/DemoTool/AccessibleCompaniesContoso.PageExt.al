// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using System.Environment.Configuration;
using Microsoft.Utilities;

pageextension 5279 "Accessible Companies Contoso" extends "Accessible Companies"
{
    layout
    {
        addafter(SetupStatus)
        {
            field(CompanyDemoData; CompanyDemoData.Get(Rec.Name))
            {
                ApplicationArea = All;
                Caption = 'Company Demo Data';
                ToolTip = 'Specifies the demo data used during the company''s creation.';
                Visible = false;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";

    begin
        if AssistedCompanySetupStatus.Get(Rec.Name) then
            CompanyDemoData.Set(Rec.Name, AssistedCompanySetupStatus."Company Demo Data")
        else
            CompanyDemoData.Set(Rec.Name, Enum::"Company Demo Data Type"::"Create New - No Data");
    end;

    var
        CompanyDemoData: Dictionary of [Text, Enum "Company Demo Data Type"];
}
