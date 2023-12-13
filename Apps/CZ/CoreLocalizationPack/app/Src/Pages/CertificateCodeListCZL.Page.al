// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.Encryption;

page 31045 "Certificate Code List CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Certificate Codes';
    PageType = List;
    SourceTable = "Certificate Code CZL";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the general identification of the certificate.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the certificate code.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Certificates)
            {
                Caption = 'Certificates';
                Image = Certificate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "Certificate List";
                RunPageLink = "Certificate Code CZL" = field(Code);
                RunPageMode = View;
                RunPageView = order(descending);
                ApplicationArea = Basic, Suite;
                ToolTip = 'View or edit the certificates that are set up for the certificate code.';
            }
        }
    }
}
