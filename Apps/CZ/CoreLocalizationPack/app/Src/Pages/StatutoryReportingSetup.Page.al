page 31108 "Statutory Reporting Setup CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Statutory Reporting Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Statutory Reporting Setup CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Company Trade Name"; Rec."Company Trade Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the trade name of company.';
                }
                field("Company Trade Name Appendix"; Rec."Company Trade Name Appendix")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the apendix of the company trade name.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of company.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        UpdateIndividualControl();
                    end;
                }
                field("Primary Business Activity Code"; Rec."Primary Business Activity Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the primary business activity code for reporting.';
                }
                field("Primary Business Activity"; Rec."Primary Business Activity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the primary business activity.';
                }
                field("Tax Payer Status"; Rec."Tax Payer Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies tax payer status.';
                }
            }
            group("Address Specification")
            {
                Caption = 'Address Specification';
                field("Municipality No."; Rec."Municipality No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the municipality number for the tax office that receives the VIES declaration or VAT Control Report.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s street.';
                }
                field("House No."; Rec."House No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s house number.';
                }
                field("Apartment No."; Rec."Apartment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies company''s apartment number.';
                }
            }
            group(Representative)
            {
                Caption = 'Representative';
                field("Company Official Nos."; Rec."Company Official Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to company officials.';
                }
                field("General Manager No."; Rec."General Manager No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of general manager.';
                }
                field("Accounting Manager No."; Rec."Accounting Manager No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of accounting manager.';
                }
                field("Finance Manager No."; Rec."Finance Manager No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of finance manager.';
                }
                group(Individual)
                {
                    Caption = 'Individual';
                    Visible = IndividualCtrlVisible;
                    field("Individual Employee No."; Rec."Individual Employee No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the employee number of individual for reporting.';
                    }
                    field("Individual First Name"; Rec."Individual First Name")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the first name of individual for reporting.';
                    }
                    field("Individual Surname"; Rec."Individual Surname")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the surname of individual for reporting.';
                    }
                    field("Individual Title"; Rec."Individual Title")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the title of individual for reporting.';
                    }
                }
            }
            Group(Signatory)
            {
                Caption = 'Signatory';
                field("Official Code"; Rec."Official Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of official company for reporting.';
                }
                field("Official Type"; Rec."Official Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of official company for reporting.';
                }
                field("Official Name"; Rec."Official Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of official company for reporting.';
                }
                field("Official First Name"; Rec."Official First Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the first name of official company for reporting.';
                }
                field("Official Surname"; Rec."Official Surname")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surname of official company for reporting.';
                }
                field("Official Birth Date"; Rec."Official Birth Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the birth date of official company for reporting.';
                }
                field("Official Reg.No.of Tax Adviser"; Rec."Official Reg.No.of Tax Adviser")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of official company for reporting.';
                }
                field("Official Registration No."; Rec."Official Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of official company for reporting.';
                }
            }
            group(Registration)
            {
                Caption = 'Registration';
                field("Tax Office Number"; Rec."Tax Office Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax office number for reporting.';
                }
                field("Tax Office Region Number"; Rec."Tax Office Region Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax office region number for reporting.';
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of company registration.';
                    Importance = Additional;
                }
                field("Equity Capital"; Rec."Equity Capital")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of equity capital.';
                    Importance = Additional;
                }
                field("Paid Equity Capital"; Rec."Paid Equity Capital")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of paid equity capital.';
                    Importance = Additional;
                }
                field("Court Authority No."; Rec."Court Authority No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the court authority.';
                }
                field("Tax Authority No."; Rec."Tax Authority No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of tax authority.';
                }
            }
            group(Intrastat)
            {
                Caption = 'Intrastat';

                field("Transaction Type Mandatory"; Rec."Transaction Type Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make transaction type specification mandatory.';
                }
                field("Transaction Spec. Mandatory"; Rec."Transaction Spec. Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you are using a mandatory transaction specification for reporting.';
                }
                field("Transport Method Mandatory"; Rec."Transport Method Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make transport method specification mandatory.';
                }
                field("Shipment Method Mandatory"; Rec."Shipment Method Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make shipment method specification mandatory.';
                }
                field("Tariff No. Mandatory"; Rec."Tariff No. Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies this option to make tariff number specification mandatory.';
                }
                field("Net Weight Mandatory"; Rec."Net Weight Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the possibility to select intrastat item''s net weight.';
                }
                field("Country/Region of Origin Mand."; Rec."Country/Region of Origin Mand.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to determine the item''s country/region of origin information.';
                }
                field("No Item Charges in Intrastat"; Rec."No Item Charges in Intrastat")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether item charges will be included in Intrastat reports. Select this option if no item charges will be included.';
                }
                field("Get Tariff No. From"; Rec."Get Tariff No. From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source for the item''s tariff number for Intrastat declaration.';
                }
                field("Get Net Weight From"; Rec."Get Net Weight From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source for the item''s net weight for Intrastat declaration.';
                }
                field("Get Country/Region of Origin"; Rec."Get Country/Region of Origin")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source for the item''s Country/Region of Origin for Intrastat declaration.';
                }
                field("Intrastat Rounding Type"; Rec."Intrastat Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rounding type for amount calculation for Intrastat declaration.';
                }
                field("Stat. Value Reporting"; Rec."Stat. Value Reporting")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies type of statistical value calculation for Intrastat declaration.';
                }
                field("Cost Regulation %"; Rec."Cost Regulation %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies percentage of cost regulation for statistical value calculation for Intrastat declaration when Stat. Value reporting is set to Percentage.';
                }
                field("Include other Period add.Costs"; Rec."Include other Period add.Costs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies setup for statistical value calculation for Intrastat declaration.';
                }
                field("Intrastat Declaration Nos."; Rec."Intrastat Declaration Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies declaration number series of intrastat.';
                }
            }
            group("VAT Statement")
            {
                Caption = 'VAT Statement';
                field("VAT Stat. Auth. Employee No."; Rec."VAT Stat. Auth. Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the authority employee number for VAT reports.';
                }
                field("VAT Stat. Filled Employee No."; Rec."VAT Stat. Filled Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the filled by employee number for VAT reports.';
                }
                field("VAT Statement Country Name"; Rec."VAT Statement Country Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country name for VAT statements.';
                }
            }
            group("VAT Control Report")
            {
                caption = 'VAT Control Report';
                field("VAT Control Report Xml Format"; Rec."VAT Control Report Xml Format")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default xml format for VAT Control Report.';
                }
                field("Simplified Tax Document Limit"; Rec."Simplified Tax Document Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value for simplified fax document for VAT Control Report.';
                }
                field("Data Box ID"; Rec."Data Box ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of certain data box.';
                }
                field("VAT Control Report E-mail"; Rec."VAT Control Report E-mail")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the email address for VAT Control Report.';
                }
                field("VAT Statement Template Name"; Rec."VAT Statement Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default VAT Statement Template.';
                }
                field("VAT Statement Name"; Rec."VAT Statement Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default VAT Statement.';
                }
                field("VAT Control Report Nos."; Rec."VAT Control Report Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for VAT Control Report.';
                }
            }
            group(VIES)
            {
                Caption = 'VIES';
                field("VIES Decl. Auth. Employee No."; Rec."VIES Decl. Auth. Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the authorized employee for VIES declaration.';
                }
                field("VIES Decl. Filled Employee No."; Rec."VIES Decl. Filled Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee, that filled VIES declaration.';
                }
                field("VIES Declaration Report No."; Rec."VIES Declaration Report No.")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the object number for VIES declaration report.';
                }
                field("VIES Declaration Report Name"; Rec."VIES Declaration Report Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the object name for VIES declaration report.';
                }
                field("VIES Declaration Export No."; Rec."VIES Declaration Export No.")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the object number for VIES declaration export.';
                }
                field("VIES Declaration Export Name"; Rec."VIES Declaration Export Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the object name for VIES declaration export.';
                }
                field("VIES Number of Lines"; Rec."VIES Number of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of lines for VIES declaration.';
                }
                field("VIES Declaration Nos."; Rec."VIES Declaration Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for VIES declaration.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."VAT Control Report XML Format" := Rec."VAT Control Report XML Format"::"03_01_03";
            Rec."Simplified Tax Document Limit" := 10000;
            Rec."VIES Declaration Report No." := Report::"VIES Declaration CZL";
            Rec."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";
            Rec.Insert();
        end;
        UpdateIndividualControl();
    end;

    var
        [InDataSet]
        IndividualCtrlVisible: Boolean;

    local procedure UpdateIndividualControl()
    begin
        IndividualCtrlVisible := (Rec."Company Type" = Rec."Company Type"::Individual);
    end;
}
