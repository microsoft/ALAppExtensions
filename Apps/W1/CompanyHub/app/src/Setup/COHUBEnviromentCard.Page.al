page 1165 "COHUB Enviroment Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "COHUB Enviroment";
    DataCaptionExpression = Rec.Name;
    Caption = 'Environment Link';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the environment.';
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the environment''s name.';
                }

                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the companies from this environment are blocked for privacy reasons.';
                }

                field("Include Demo Companies"; Rec."Include Demo Companies")
                {
                    Caption = 'Include Demo Companies';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the demo companies from this environment should be included or not.';
                }

                field(Link; Rec.Link)
                {
                    Caption = 'Environment Link';
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ToolTip = 'Specifies the link used to access the environment''s companies.';
                }

                field("Group Code"; Rec."Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Code', Comment = 'Group';
                    ToolTip = 'Select a group for this client.', Comment = 'Select a group for this client.';
                }
            }

            group(AddressAndContact)
            {
                Caption = 'Address & Contact';
                group(AddressDetails)
                {
                    Caption = 'Address';
                    field(Address; Rec.Address)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the company''s address.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies additional address information.';
                    }

                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the country or region of the address.';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the company''s city.';
                    }

                    field(County; Rec.County)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the state, province or county as a part of the address.';
                    }

                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Promoted;
                        ToolTip = 'Specifies the postal code.';
                    }
                }

                group(ContactDetails)
                {
                    Caption = 'Contact';

                    field(ContactName; Rec."Contact Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Contact Name';
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of your primary contact.';
                    }

                    field("Phone No."; Rec."Contact Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the telephone number of your primary contact.';
                    }

                    field("E-Mail"; Rec."Contact E-Mail")
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = EMail;
                        Importance = Promoted;
                        ToolTip = 'Specifies the email address of primary contact.';
                    }

                    field("Home Page"; Rec."Home Page")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the company''s home page address.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestEnviromentLink)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test the connection';
                Image = LinkWithExisting;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Validates that you have access to the specified environment.';

                trigger OnAction()
                var
                    COHUBCore: Codeunit "COHUB Core";
                begin
                    COHUBCore.ValidateEnviromentUrl(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Include Demo Companies" := true;
    end;

    trigger OnOpenPage()
    var
        COHUBCore: Codeunit "COHUB Core";
    begin
        COHUBCore.ShowNotSupportedOnPremNotification();
    end;
}