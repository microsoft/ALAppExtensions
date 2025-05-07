// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

page 6441 "SignUp Metadata Profiles"
{
    PageType = List;
    SourceTable = "SignUp Metadata Profile";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Profile ID"; Rec."Profile ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec."Profile Name")
                {
                    ApplicationArea = All;
                }
                field("Process Identifier Scheme"; Rec."Process Identifier Scheme")
                {
                    ApplicationArea = All;
                }
                field("Process Identifier Value"; Rec."Process Identifier Value")
                {
                    ApplicationArea = All;
                }
                field("Document Identifier Scheme"; Rec."Document Identifier Scheme")
                {
                    ApplicationArea = All;
                }
                field("Document Identifier Value"; Rec."Document Identifier Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
