// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains the allowed companies for the current user.
/// </summary>
page 9210 "Accessible Companies"
{
    Caption = 'Allowed Companies';
    Editable = false;
    PageType = List;
    SourceTable = Company;
    SourceTableTemporary = true;
    Permissions = tabledata Company = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CompanyDisplayName; Rec."Display Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the display name that is defined for the company. If a display name is not defined, then the company name is used.';
                }
                field("Evaluation Company"; Rec."Evaluation Company")
                {
                    ApplicationArea = All;
                    Caption = 'Evaluation Company';
                    Editable = false;
                    ToolTip = 'Specifies that the company is for trial purposes only, and that a subscription has not been purchased.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create New Company")
            {
                AccessByPermission = TableData Company = I;
                ApplicationArea = Basic, Suite;
                Caption = 'Create New Company';
                Image = Company;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Get assistance with creating a new company.';
                Visible = SoftwareAsAService;

                trigger OnAction()
                begin
                    // Action invoked through event subscriber to avoid hard coupling to other objects,
                    // as this page is part of the Cloud Manager.
                    Initialize();
                end;
            }
        }
    }

    procedure Initialize()
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        SoftwareAsAService := EnvironmentInformation.IsSaaS();
        UserSettingsImpl.GetAllowedCompaniesForCurrentUser(Rec);
    end;

    var
        SoftwareAsAService: Boolean;
}

