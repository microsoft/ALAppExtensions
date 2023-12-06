// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Utilities;

page 11766 "Company Official Card CZL"
{
    Caption = 'Company Official Card';
    PageType = Card;
    SourceTable = "Company Official CZL";
    PromotedActionCategories = 'New,Process,Report,Company Official,Navigate';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of company official.';
                    Visible = NoFieldVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee number for the company official.';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s first name.';
                    ShowMandatory = true;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s middle name.';
                    Importance = Additional;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s last name.';
                    ShowMandatory = true;
                    Importance = Promoted;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s job title.';
                    Importance = Promoted;
                }
                field(Initials; Rec.Initials)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s initials.';
                    Importance = Additional;
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s search name.';
                }
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
                    Importance = Additional;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the company officials record was last modified.';
                    Importance = Additional;
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';
                field(Address; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s address.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s address 2.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s city.';
                }
                group(Control31)
                {
                    ShowCaption = false;
                    Visible = IsCountyVisible;
                    field(County; Rec.County)
                    {
                        ApplicationArea = BasicHR;
                        ToolTip = 'Specifies the county of the employee.';
                    }
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Code/City';
                    ToolTip = 'Specifies the company official''s post code.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s country and region.';
                    trigger OnValidate()
                    begin
                        IsCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
                    end;
                }
                field(ShowMap; ShowMapLbl)
                {
                    Caption = 'Show on Map';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                    StyleExpr = true;
                    ToolTip = 'Specifies the company official''s address on your preferred online map.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.Update(true);
                        Rec.DisplayMap();
                    end;
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s phone number.';
                    Importance = Promoted;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s mobile phone number.';
                    Importance = Promoted;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the e-mail address for the company official.';
                    Importance = Promoted;
                }
                field("Fax No."; Rec."Fax No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s fax number.';
                }
            }
        }
        area(factboxes)
        {
            part("Company Official Picture CZL"; "Company Official Picture CZL")
            {
                ApplicationArea = BasicHR;
                SubPageLink = "No." = field("No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(11793), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("Company Official")
            {
                Caption = 'Company Official';
                Image = Employee;
                action(Attachments)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attachments';
                    Image = Attach;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
                action("&Picture")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Picture';
                    Image = Picture;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    RunObject = page "Company Official Picture CZL";
                    RunPageLink = "No." = field("No.");
                    ToolTip = 'View or add a picture of the employee or, for example, the company''s logo.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetNoFieldVisible();
        IsCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
    end;

    var
        FormatAddress: Codeunit "Format Address";
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        ShowMapLbl: Label 'Show on Map';
        NoFieldVisible: Boolean;
        IsCountyVisible: Boolean;

    local procedure SetNoFieldVisible()
    begin
        NoFieldVisible := CompanyOfficialNoIsVisible();
    end;

    procedure CompanyOfficialNoIsVisible(): Boolean
    var
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := DetermineCompanyOfficialSeriesNo();
        exit(DocumentNoVisibility.ForceShowNoSeriesForDocNo(NoSeriesCode));
    end;

    local procedure DetermineCompanyOfficialSeriesNo(): Code[20]
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        DocumentNoVisibility.CheckNumberSeries(CompanyOfficialCZL, StatutoryReportingSetupCZL."Company Official Nos.", CompanyOfficialCZL.FieldNo("No."));
        exit(StatutoryReportingSetupCZL."Company Official Nos.");
    end;

}
