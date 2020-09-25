page 10678 "SAF-T VAT Posting Setup"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    SourceTable = "VAT Posting Setup";
    Caption = 'SAF-T VAT Posting Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                    Editable = false;
                }
                field("VAT Calculation Type"; "VAT Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how VAT will be calculated for purchases or sales of items with this particular combination of VAT business posting group and VAT product posting group.';
                    Editable = false;
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant VAT rate for the particular combination of VAT business posting group and VAT product posting group. Do not enter the percent sign, only the number. For example, if the VAT rate is 25 %, enter 25 in this field.';
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the VAT posting setup';
                    Editable = false;
                }
                field("Sales SAF-T Tax Code"; "Sales SAF-T Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the sales VAT entries.';
                    Editable = false;
                }
                field("Purchase SAF-T Tax Code"; "Purchase SAF-T Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the TaxCode XML node in the SAF-T file for the purchase VAT entries.';
                    Editable = false;
                }
                field("Sales SAF-T Standard Tax Code"; "Sales SAF-T Standard Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the sales VAT entries.';
                    ShowMandatory = SalesStandardTaxCodeMandatory;
                }
                field("Purch. SAF-T Standard Tax Code"; "Purch. SAF-T Standard Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the VAT posting setup that will be used for the StandardTaxCode XML node in the SAF-T file for the purchase VAT entries.';
                    ShowMandatory = PurchStandardTaxCodeMandatory;
                }
            }
        }
    }

    var
        SalesStandardTaxCodeMandatory: Boolean;
        PurchStandardTaxCodeMandatory: Boolean;

    trigger OnAfterGetRecord()
    begin
        CalcTaxCodeMandatoryStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcTaxCodeMandatoryStyle();
    end;

    local procedure CalcTaxCodeMandatoryStyle()
    begin
        SalesStandardTaxCodeMandatory := ("Sales VAT Account" <> '') and ("Sales SAF-T Standard Tax Code" = '');
        PurchStandardTaxCodeMandatory := ("Purchase VAT Account" <> '') and ("Purch. SAF-T Standard Tax Code" = '');
    end;
}