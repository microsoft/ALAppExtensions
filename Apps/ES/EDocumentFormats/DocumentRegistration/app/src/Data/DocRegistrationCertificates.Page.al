// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using System.Security.AccessControl;
using System.Security.Encryption;

page 10779 "Doc. Registration Certificates"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Certificates';
    CardPageID = "Doc. Registration Certificate";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Isolated Certificate";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the identifier for the certificate.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the certificate.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the availability of the certificate. Company gives all users in this specific company access to the certificate. User gives access to a specific user in any company. Company and User gives access to a specific user in the specific company.';
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the certificate will expire.';
                }
                field("Has Private Key"; Rec."Has Private Key")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the certificate has a private key.';
                }
                field(ThumbPrint; Rec.ThumbPrint)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the certificate thumbprint.';
                }
                field("Issued By"; Rec."Issued By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the certificate authority that issued the certificate.';
                }
                field("Issued To"; Rec."Issued To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the person, organization, or domain that the certificate was issued to.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Change User")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Change User';
                Image = UserSetup;
                RunPageOnRec = true;
                ToolTip = 'Assign the certificate to a different user.';

                trigger OnAction()
                begin
                    if Rec.Scope = Rec.Scope::Company then
                        Error(AssignUserScopeErr);
                    Page.Run(Page::"Change User", Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        User: Record User;
    begin
        Rec.FilterGroup(2);
        if User.Get(UserSecurityId()) then;
        Rec.SetFilter("Company ID", '%1|%2', '', CompanyName);
        Rec.SetFilter("User ID", '%1|%2', '', User."User Name");
    end;

    var
        AssignUserScopeErr: Label 'This certificate is available to everyone in the company, so you cannot assign it to a specific user. To do that, you can add a new certificate with a different option chosen in the Available To field.';
}

