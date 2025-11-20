// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

pageextension 47200 "SL Migration Configuration Ext" extends "SL Migration Configuration"
{
    layout
    {
        addafter(Classes)
        {
            group(Vendor1099)
            {
                Caption = 'Vendor 1099';
                InstructionalText = 'Choose whether to migrate vendor 1099 information from Dynamics SL to Business Central. This option is only available if the Payables module is selected for migration.';

                field("Migrate Current 1099 Year"; Rec."Migrate Current 1099 Year")
                {
                    ApplicationArea = All;
                    Caption = 'Migrate Current 1099 Year';
                    ToolTip = 'Specifies whether to migrate current 1099 year information.';

                    trigger OnValidate()
                    var
                        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
                    begin
                        SLCompanyAdditionalSettings.SetFilter(Name, '<>%1', '');
                        if SLCompanyAdditionalSettings.FindSet() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Current 1099 Year", Rec."Migrate Current 1099 Year");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Next 1099 Year"; Rec."Migrate Next 1099 Year")
                {
                    ApplicationArea = All;
                    Caption = 'Migrate Next 1099 Year';
                    ToolTip = 'Specifies whether to migrate next 1099 year information.';

                    trigger OnValidate()
                    var
                        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
                    begin
                        SLCompanyAdditionalSettings.SetFilter(Name, '<>%1', '');
                        if SLCompanyAdditionalSettings.FindSet() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Next 1099 Year", Rec."Migrate Next 1099 Year");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }
        }
    }
}



